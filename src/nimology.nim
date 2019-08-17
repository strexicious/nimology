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
    -0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,

    -0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,

    -0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,

     0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,

    -0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
     0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
     0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,

    -0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
     0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
     0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,

    -1.0'f32, -1.0'f32, -0.5'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
     1.0'f32, -1.0'f32, -0.5'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
     1.0'f32,  1.0'f32, -0.5'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32, 1.0'f32,
     1.0'f32,  1.0'f32, -0.5'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32, 1.0'f32,
    -1.0'f32,  1.0'f32, -0.5'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32,
    -1.0'f32, -1.0'f32, -0.5'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
  ]

discard ngn.addRawObject("sqware", data, @[(3'i32, 0), (3'i32, 3), (2'i32, 6)])

# texture data
let imgData1 = stbiLoad("res/sample.png", stbiRGB)
let imgData2 = stbiLoad("res/sample2.png", stbiRGB)

ngn.addTexture(GL_TEXTURE0, imgData1)
ngn.addTexture(GL_TEXTURE1, imgData2)

imageFree(imgData1)
imageFree(imgData2)

# add renders with all the data
let modelUni = glGetUniformLocation(sp, "model")
let viewUni = glGetUniformLocation(sp, "view")
let projUni = glGetUniformLocation(sp, "proj")
let overrideColorUni = glGetUniformLocation(sp, "overrideColor")

var model = mat4f(1.0)
var view = lookAt(vec3f(2.5), vec3f(0.0), vec3f(0.0, 0.0, 1.0))
var proj = perspective(radians(GLfloat(45.0)), 800.0 / 600.0, 1.0, 10.0)

let sqwareRender = proc(obj: Object): void =
  glUseProgram(sp)
  glUniform1i(glGetUniformLocation(sp, "texKitten"), 0)
  glUniform1i(glGetUniformLocation(sp, "texPuppy"), 1)
  
  glUniformMatrix4fv(modelUni, 1, false, model.caddr)
  glUniformMatrix4fv(viewUni, 1, false, view.caddr)
  glUniformMatrix4fv(projUni, 1, false, proj.caddr)
  
  glBindVertexArray(obj.vao)
  glDrawArrays(GL_TRIANGLES, 0, 36)

let groundRender = proc(obj: Object): void =
  glEnable(GL_STENCIL_TEST)
  glStencilFunc(GL_ALWAYS, 1, 0xFF)
  glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE)
  glStencilMask(0xFF)
  glDepthMask(false)
  glClear(GL_STENCIL_BUFFER_BIT)

  glDrawArrays(GL_TRIANGLES, 36, 6)

let refSqwareRender = proc(obj: Object): void =
  glStencilFunc(GL_EQUAL, 1, 0xFF)
  glStencilMask(0x00)
  glDepthMask(true)
  
  model = model
    .translate(vec3f(0.0, 0.0, -1.0))
    .scale(vec3f(1.0, 1.0, -1.0))
  
  glUniformMatrix4fv(modelUni, 1, false, model.caddr)

  glUniform3f(overrideColorUni, 0.3, 0.3, 0.3)
  glDrawArrays(GL_TRIANGLES, 0, 36)
  glUniform3f(overrideColorUni, 1.0, 1.0, 1.0)
  
  glDisable(GL_STENCIL_TEST)

discard ngn.addRender("sqware", sqwareRender)
discard ngn.addRender("sqware", groundRender)
discard ngn.addRender("sqware", refSqwareRender)

# add updates
let sqwareUpdate = proc(delta: GLfloat): void =
  model = mat4f(1.0).rotate(glfwGetTime(), vec3f(0.0, 0.0, 1.0))

ngn.addUpdate(sqwareUpdate)

ngn.loopEngine()
discard ngn.stopEngine()
