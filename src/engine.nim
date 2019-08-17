from math import sin

import tables
import sets
import result
import nimgl/[glfw, opengl, stb/image]

type
  Engine* = object
    WIDTH: int32
    HEIGHT: int32
    window*: GLFWWindow
    updates: seq[proc(delta: GLfloat): void]
    renders: seq[(string, proc(obj: Object): void)]
    textures: seq[GLuint]
    shaderPrograms: seq[GLuint]
    objects: Table[string, Object]
  
  Object* = object
    vao*: GLuint
    vbo*: GLuint
    ebo*: GLuint

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
  glfwWindowHint(whResizable, GLFW_TRUE)
  
  let w = glfwCreateWindow(width, height, "nimology engine", nil, nil)
  if w.isNil:
    glfwTerminate()
    result.err("failed to create a window")
    return
  
  w.makeContextCurrent()
  
  if not glInit():
    w.destroyWindow()
    glfwTerminate()
    result.err("failed to start OpenGL")
    return
  
  glEnable(GL_DEPTH_TEST)
  glClearColor(r, g, b, 1.0)

  result.ok(Engine(
    WIDTH: width,
    HEIGHT: height,
    window: w,
  ))
  engineAlreadyStarted = true

proc getShaderLog(s: GLuint): cstring =
  var logLength: GLsizei
  glGetShaderiv(s, GL_INFO_LOG_LENGTH, logLength.addr)
  
  var logText = alloc(logLength)
  glGetShaderInfoLog(s, logLength, nil, cast[cstring](logText))
  
  result = cast[cstring](logText)
  dealloc(logText)

proc regularShader*(engine: var Engine, vsource: var cstring, fsource: var cstring): Result[GLuint, string] =
  let vshader = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(vshader, 1, vsource.addr, nil)
  glCompileShader(vshader)

  let fshader = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(fshader, 1, fsource.addr, nil)
  glCompileShader(fshader)

  var status: GLenum
  glGetShaderiv(vshader, GL_COMPILE_STATUS, cast[ptr GLint](status.addr))
  if status == GL_FALSE:
    result.err("Vertex shader error: " & $getShaderLog(vshader))
    return

  glGetShaderiv(fshader, GL_COMPILE_STATUS, cast[ptr GLint](status.addr))
  if status == GL_FALSE:
    result.err("Fragment shader error: " & $getShaderLog(fshader))
    return
  
  let program = glCreateProgram()
  glAttachShader(program, vshader)
  glAttachShader(program, fshader)
  glLinkProgram(program)
  glDetachShader(program, vshader)
  glDetachShader(program, fshader)
  glDeleteShader(vshader)
  glDeleteShader(fshader)

  engine.shaderPrograms.add(program)

  result.ok(program)

proc addRawObject*(
  engine: var Engine,
  name: string,
  data: var seq[GLfloat],
  attribs: seq[(GLsizei, GLsizeiptr)] # (size, offset)
): Result[void, string] =
  if engine.objects.hasKey(name):
    result.err("object already present")
    return
  
  var
    vao: GLuint
    vbo: GLuint
  
  glGenVertexArrays(1, vao.addr)
  glGenBuffers(1, vbo.addr)

  glBindVertexArray(vao)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, cast[GLsizeiptr](GLfloat.sizeof * data.len), data[0].addr, GL_STATIC_DRAW)

  var stride: GLsizei = 0
  for attr in attribs.items:
    stride += attr[0]

  for i, attr in attribs.pairs:
    glVertexAttribPointer(cast[GLuint](i), cast[GLint](attr[0]), EGL_FLOAT, false,
      cast[GLsizei](stride * GLfloat.sizeof), cast[pointer](attr[1] * GLfloat.sizeof))
    glEnableVertexAttribArray(cast[GLuint](i))
  
  engine.objects[name] = Object(vao: vao, vbo: vbo)
  glBindVertexArray(0)

proc rawObjectIndices*(engine: var Engine, name: string, indices: var seq[GLuint]): Result[void, string] =
  if not engine.objects.hasKey(name):
    result.err("invalid object")
    return
  
  glBindVertexArray(engine.objects[name].vao)
  
  var ebo: GLuint
  glGenBuffers(1, ebo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLsizeiptr(GLuint.sizeof * indices.len), indices[0].addr, GL_STATIC_DRAW)
  engine.objects[name].ebo = ebo
  glBindVertexArray(0)

proc addTexture*(engine: var Engine, unit: GLenum, imgData: ImageData): void =
  glActiveTexture(unit)
  
  var tex: Gluint
  glGenTextures(1, tex.addr)
  glBindTexture(GL_TEXTURE_2D, tex)
  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GLint(GL_REPEAT))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GLint(GL_REPEAT))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GLint(GL_LINEAR))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GLint(GL_LINEAR))

  glTexImage2D(GL_TEXTURE_2D, 0, GLint(GL_RGB), imgData.width, imgData.height, 0, GL_RGB,
    GL_UNSIGNED_BYTE, cast[pointer](imgData.data))
  engine.textures.add(tex)

proc addRender*(
  engine: var Engine,
  name: string,
  render: proc(obj: Object): void
): Result[void, string] =
  if not engine.objects.hasKey(name):
    result.err("no such object: " & name)
    return
  
  engine.renders.add((name, render))

proc addUpdate*(engine: var Engine, update: proc(delta: GLfloat): void): void =
  engine.updates.add(update)

proc loopEngine*(engine: var Engine): void =
  var lastTime = glfwGetTime()
  while not engine.window.windowShouldClose:
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

    # get input and queue updates
    let now = glfwGetTime()
    let deltaTime = now - lastTime
    lastTime = now
    
    # run the updates
    for update in engine.updates:
      update(deltaTime)

    # run the renderers
    for render in engine.renders:
      render[1](engine.objects[render[0]])
          
    if engine.window.getKey(keyEscape) == kaPress:
      engine.window.setWindowShouldClose(true)
      
    engine.window.swapBuffers()
    glfwPollEvents()

proc stopEngine*(engine: var Engine): Result[void, string] =
  if not engineAlreadyStarted:
    result.err("engine not running")
    return
  
  for sp in engine.shaderPrograms:
    glDeleteProgram(sp)
  
  for obj in engine.objects.values:
    glDeleteBuffers(1, unsafeAddr obj.vbo)

    if obj.ebo != 0:
      glDeleteBuffers(1, unsafeAddr obj.ebo)
    
    glDeleteVertexArrays(1, unsafeAddr obj.vao)
  
  if engine.textures.len != 0:
    glDeleteTextures(GLsizei(engine.textures.len), engine.textures[0].addr)
  
  # this also destroys OpenGL context
  engine.window.destroyWindow()
  glfwTerminate()
