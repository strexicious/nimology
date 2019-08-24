from math import sin
from camera import moveCamera, setAngles, MoveDir

import streams
import strutils
import result
import nimasset/obj
import nimgl/[glfw, opengl, stb/image]
import gui
import renderer/[text, model]
import command


stbiSetFlipVerticallyOnLoad(true)

type
  Engine* = object
    WIDTH: int32
    HEIGHT: int32
    window: GLFWWindow
    gui: Gui
    mr: ModelRenderer
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
  
  if engine.imode == im_interactive and key == keyW:
    engine.mr.cam.moveCamera(md_forward)
    engine.mr.updateView()
    return
  
  if engine.imode == im_interactive and key == keyS:
    engine.mr.cam.moveCamera(md_backward)
    engine.mr.updateView()
    return

let mouseHandler = proc(window: GLFWWindow, xpos: float64, ypos: float64): void {.cdecl.} =
  let engine = cast[ptr Engine](window.getWindowUserPointer())
  engine.mr.cam.setAngles(xpos, ypos)
  engine.mr.updateView()

let debugCB = proc(
  source: GLenum,
  `type`: GLenum,
  id: GLuint,
  severity: GLenum,
  length: GLsizei,
  message: cstring,
  userParam: pointer
): void {.cdecl.} =
  echo source, ", ", `type`, ": ", message

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
  glfwWindowHint(whOpenglDebugContext, GLFW_TRUE)
  
  let w = glfwCreateWindow(width, height, "nimology engine", nil, nil)
  if w.isNil:
    result.err("failed to create a window")
    return

  w.makeContextCurrent()
  w.setCursorPos(0, 0)
  w.setInputMode(EGLFW_CURSOR, GLFW_CURSOR_DISABLED)
  
  if not glInit():
    w.destroyWindow()
    glfwTerminate()
    result.err("failed to start OpenGL")
    return
  
  glEnable(GL_DEBUG_OUTPUT)
  glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS)
  glDebugMessageCallback(debugCB, nil)
  glClearColor(r, g, b, 1.0)

  var engine = cast[ptr Engine](alloc(Engine.sizeof))
  engine.WIDTH = width
  engine.HEIGHT = height
  engine.window = w
  engine.imode = im_interactive
  engine.ch = new CommandHandler
  engine.mr = newModelRenderer(engine.WIDTH, engine.HEIGHT)

  let info = newGuiInfo([1.0'f32, 1.0'f32, 1.0'f32], engine.ch)
  engine.tr = newTextRenderer("res/fonts/font.png")
  engine.gui = newGui(width, height, info, engine.tr)
  result.ok(engine)

  engine.window.setWindowUserPointer(engine)
  discard engine.window.setKeyCallback(handler)
  discard engine.window.setCursorPosCallback(mouseHandler)
  
  let loadCmd: CmdHandler = proc(params: openarray[string]): void =
    if params.len == 0:
      echo "Need an obj filename"
      return

    let
      loader: ObjLoader = new ObjLoader
      f = open(params[0])
      fs = newFileStream(f)

    engine.mr.emptyData()
    var tempVerts: seq[GLfloat] = @[]
    let taddVertex = proc(x, y, z: GLfloat) =
      tempVerts.add([x, y, z])
    
    let taddTexture = proc(u, v, w: float) = discard

    let taddFace = proc(vi0, vi1, vi2, ti0, ti1, ti2, ni0, ni1, ni2: int) =
      engine.mr.addVertex(tempVerts[vi0*3-3], tempVerts[vi0*3-2], tempVerts[vi0*3-1])
      engine.mr.addVertex(tempVerts[vi1*3-3], tempVerts[vi1*3-2], tempVerts[vi1*3-1])
      engine.mr.addVertex(tempVerts[vi2*3-3], tempVerts[vi2*3-2], tempVerts[vi2*3-1])

    loadMeshData(loader, fs, taddVertex, taddTexture, taddFace)
    engine.mr.uploadData()
  
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
    engine.mr.render()
    engine.gui.drawGui()
      
    engine.window.swapBuffers()
    glfwPollEvents()

proc stopEngine*(engine: var ptr Engine): Result[void, string] =
  if not engineAlreadyStarted:
    result.err("engine not running")
    return
  
  engine.mr.cleanModelRenderer()
  engine.tr.cleanTextRenderer()
  # this also destroys OpenGL context
  engine.window.destroyWindow()
  glfwTerminate()

  engineAlreadyStarted = false
  dealloc(engine)
  result.ok()
