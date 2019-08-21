from math import sin

import result
import nimgl/[glfw, opengl, stb/image]
import gui
import renderer/text

stbiSetFlipVerticallyOnLoad(true)

type
  Engine* = object
    WIDTH: int32
    HEIGHT: int32
    window: GLFWWindow
    gui: Gui
    tr: TextRenderer

var engineAlreadyStarted = false

proc startEngine*(width: int32, height: int32, r: float, g: float, b: float): Result[Engine, string] =
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

  var engine = Engine(WIDTH: width, HEIGHT: height, window: w)

  let info = newGuiInfo([1.0'f32, 1.0'f32, 1.0'f32])
  engine.tr = newTextRenderer("res/fonts/font.png")
  engine.gui = newGui(width, height, info, engine.tr)
  result.ok(engine)

  engineAlreadyStarted = true

proc loopEngine*(engine: var Engine): void =
  var lastTime = glfwGetTime()
  while not engine.window.windowShouldClose:
    glClear(GL_COLOR_BUFFER_BIT)
    # get input and queue updates
    let now = glfwGetTime()
    let deltaTime = now - lastTime
    lastTime = now

    engine.gui.info.setFps(uint16(1 / deltaTime))
    engine.gui.drawGui()

    if engine.window.getKey(keyEscape) == kaPress:
      engine.window.setWindowShouldClose(true)
      
    engine.window.swapBuffers()
    glfwPollEvents()

proc stopEngine*(engine: var Engine): Result[void, string] =
  if not engineAlreadyStarted:
    result.err("engine not running")
    return
  
  engine.tr.cleanTextRenderer()
  # this also destroys OpenGL context
  engine.window.destroyWindow()
  glfwTerminate()

  engineAlreadyStarted = false
  result.ok()
