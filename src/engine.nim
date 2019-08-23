from math import sin

import result
import nimgl/[glfw, opengl, stb/image]
import gui
import renderer/text
import command

stbiSetFlipVerticallyOnLoad(true)

type
  Engine* = object
    WIDTH: int32
    HEIGHT: int32
    window: GLFWWindow
    gui: Gui
    tr: TextRenderer
    ch: CommandHandler
    imode: InputMode
  
  InputMode = enum
    im_interactive, im_command

let handler = proc(window: GLFWWindow, key: GLFWKey, scancode: int32, action: GLFWKeyAction, mods: GLFWKeyMod): void {.cdecl.} =
  var engine = cast[ptr Engine](window.getWindowUserPointer())

  if engine.imode == im_command and key == keyEscape:
    engine.imode = im_interactive
    engine.ch.clearCurrCmd()
    return

  if engine.imode == im_command:
    engine.ch.handleInput(key, scancode, action, mods)
    if key == keyEnter:
      engine.imode = im_interactive
    return

  if engine.imode == im_interactive and key == keyEscape and action == kaPress:
    engine.window.setWindowShouldClose(true)
    return

  if engine.imode == im_interactive and key == keyT:
    engine.imode = im_command
    return

let loadCmd: CmdHandler = proc(params: openarray[string]): void =
  echo params

var engineAlreadyStarted = false

proc startEngine*(width: int32, height: int32, r, g, b: float): Result[ptr Engine, string] =
  if engineAlreadyStarted:
    result.err("engine already running")
    return
  
  if not glfwInit():
    result.err("failed to start glfw")
    return
  
  glfwWindowHint(whContextVersionMajor, 3)
  glfwWindowHint(whContextVersionMinor, 2)
  glfwWindowHint(whOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(whOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(whResizable, GLFW_FALSE)
    
  let w = glfwCreateWindow(width, height, "nimology engine", nil, nil)
  if w.isNil:
    result.err("failed to create a window")
    return

  w.makeContextCurrent()
  
  if not glInit():
    w.destroyWindow()
    glfwTerminate()
    result.err("failed to start OpenGL")
    return
    
  glClearColor(r, g, b, 1.0)

  var engine = cast[ptr Engine](alloc(Engine.sizeof))
  engine.WIDTH = width
  engine.HEIGHT = height
  engine.window = w
  engine.imode = im_interactive
  engine.ch = new CommandHandler

  let info = newGuiInfo([1.0'f32, 1.0'f32, 1.0'f32], engine.ch)
  engine.tr = newTextRenderer("res/fonts/font.png")
  engine.gui = newGui(width, height, info, engine.tr)
  result.ok(engine)

  engine.window.setWindowUserPointer(engine)
  discard engine.window.setKeyCallback(handler)

  engine.ch.registerHandler("load", loadCmd)

  engineAlreadyStarted = true

proc loopEngine*(engine: var ptr Engine): void =
  var lastTime = glfwGetTime()
  while not engine.window.windowShouldClose:
    glClear(GL_COLOR_BUFFER_BIT)
    # get input and queue updates
    let now = glfwGetTime()
    let deltaTime = now - lastTime
    lastTime = now

    engine.gui.info.setFps(uint16(1 / deltaTime))
    engine.gui.drawGui()
      
    engine.window.swapBuffers()
    glfwPollEvents()

proc stopEngine*(engine: var ptr Engine): Result[void, string] =
  if not engineAlreadyStarted:
    result.err("engine not running")
    return
  
  engine.tr.cleanTextRenderer()
  # this also destroys OpenGL context
  engine.window.destroyWindow()
  glfwTerminate()

  engineAlreadyStarted = false
  dealloc(engine)
  result.ok()
