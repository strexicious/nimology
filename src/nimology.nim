from math import sin

import result
import glm
import nimgl/[glfw, opengl, stb/image]
import engine

let engineErrorMapper = proc(x: string): string = "Engine error: " & x

var ngn = startEngine(800, 600, 0.54, 0.41, 0.06)
  .mapErr(engineErrorMapper)
  .get()

# shader
var vertex_source: cstring = readFile("res/shaders/shader1.vert")
var fragment_source: cstring = readFile("res/shaders/shader1.frag")

let sp = ngn
  .regularShader(vertex_source, fragment_source)
  .mapErr(engineErrorMapper)
  .get()

# vertex data
var data: seq[GLfloat] =
  @[
    -0.5'f32,  0.5'f32, 1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
     0.5'f32,  0.5'f32, 0.0'f32, 1.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
     0.5'f32, -0.5'f32, 0.0'f32, 0.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
  ]
var indices: seq[GLuint] =
  @[
    0'u32, 1'u32, 2'u32,
    2'u32, 3'u32, 0'u32,
  ]

discard ngn.addRawObject("sqware", data, @[(2'i32, 0), (3'i32, 2), (2'i32, 5)])
discard ngn.rawObjectIndices("sqware", indices)

# texture data
let imgData1 = stbiLoad("res/sample.png", stbiRGB)
let imgData2 = stbiLoad("res/sample2.png", stbiRGB)

ngn.addTexture(GL_TEXTURE0, imgData1)
ngn.addTexture(GL_TEXTURE1, imgData2)

imageFree(imgData1)
imageFree(imgData2)

# add renders with all the data
var model = mat4f(1.0)
var view = lookAt(vec3f(1.2), vec3f(0.0), vec3f(0.0, 0.0, 1.0))
var proj = perspective(radians(GLfloat(45.0)), 800.0 / 600.0, 1.0, 10.0)

let sqwareRender = proc(): void =
  glUseProgram(sp)
  glUniform1i(glGetUniformLocation(sp, "texKitten"), 0)
  glUniform1i(glGetUniformLocation(sp, "texPuppy"), 1)
  
  let modelUni = glGetUniformLocation(sp, "model")
  glUniformMatrix4fv(modelUni, 1, false, model.caddr)

  let viewUni = glGetUniformLocation(sp, "view")
  glUniformMatrix4fv(viewUni, 1, false, view.caddr)

  let projUni = glGetUniformLocation(sp, "proj")
  glUniformMatrix4fv(projUni, 1, false, proj.caddr)

discard ngn.addRender("sqware", sqwareRender)

# add updates
let sqwareUpdate = proc(delta: GLfloat): void =
  model = mat4f(1.0).rotate(glfwGetTime(), vec3f(0.0, 0.0, 1.0))

ngn.addUpdate(sqwareUpdate)

ngn.loopEngine()
discard ngn.stopEngine()
