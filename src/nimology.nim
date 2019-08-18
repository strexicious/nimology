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
var vertex_source2: cstring = readFile("res/shaders/shader2.vert")
var fragment_source2: cstring = readFile("res/shaders/shader2.frag")

let sp = ngn
  .regularShader(vertex_source, fragment_source)
  .mapErr(engineErrorMapper)
  .get()

let sp2 = ngn
  .regularShader(vertex_source2, fragment_source2)
  .mapErr(engineErrorMapper)
  .get()

# framebuffering
var texColorBuffer: array[2, GLuint]
glGenTextures(2, texColorBuffer[0].addr)

glActiveTexture(GL_TEXTURE2)
glBindTexture(GL_TEXTURE_2D, texColorBuffer[0])
glTexImage2D(GL_TEXTURE_2D, 0, GLint(GL_RGB), 800, 600, 0, GL_RGB, GL_UNSIGNED_BYTE, nil)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GLint(GL_LINEAR))
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GLint(GL_LINEAR))

glActiveTexture(GL_TEXTURE3)
glBindTexture(GL_TEXTURE_2D, texColorBuffer[1])
glTexImage2D(GL_TEXTURE_2D, 0, GLint(GL_RGB), 800, 600, 0, GL_RGB, GL_UNSIGNED_BYTE, nil)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GLint(GL_LINEAR))
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GLint(GL_LINEAR))

var dsRbo: array[2, GLuint]
glGenRenderbuffers(2, dsRbo[0].addr)
glBindRenderbuffer(GL_RENDERBUFFER, dsRbo[0])
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, 800, 600)
glBindRenderbuffer(GL_RENDERBUFFER, dsRbo[1])
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, 800, 600)

var framebuffer: array[2, GLuint]
glGenFramebuffers(2, framebuffer[0].addr)

glBindFramebuffer(GL_FRAMEBUFFER, framebuffer[0])
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texColorBuffer[0], 0)
glFramebufferRenderBuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, dsRbo[0])
echo "framebuffer[0] complete: ", GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus(GL_FRAMEBUFFER)

glBindFramebuffer(GL_FRAMEBUFFER, framebuffer[1])
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texColorBuffer[1], 0)
glFramebufferRenderBuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, dsRbo[1])
echo "framebuffer[1] complete: ", GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus(GL_FRAMEBUFFER)

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

discard ngn.addRawObject("shiny", data, @[(3'i32, 0), (3'i32, 3), (2'i32, 6)])

var sqware: seq[GLfloat] =
  @[
    -0.5'f32,  0.5'f32, 0.0'f32, 1.0'f32,
     0.5'f32,  0.5'f32, 1.0'f32, 1.0'f32,
     0.5'f32, -0.5'f32, 1.0'f32, 0.0'f32,
    -0.5'f32, -0.5'f32, 0.0'f32, 0.0'f32,
  ]
var sqwareIndices: seq[GLuint] =
  @[
    0'u32, 1'u32, 2'u32,
    2'u32, 3'u32, 0'u32,
  ]

discard ngn.addRawObject("sqware", sqware, @[(2'i32, 0), (2'i32, 2)])
discard ngn.rawObjectIndices("sqware", sqwareIndices)

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

let shinyRenderCore = proc(obj: Object): void =
  glClearColor(0.54, 0.41, 0.06, 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glUseProgram(sp)
  glUniform1i(glGetUniformLocation(sp, "texKitten"), 0)
  glUniform1i(glGetUniformLocation(sp, "texPuppy"), 1)

  glUniformMatrix4fv(modelUni, 1, false, model.caddr)
  glUniformMatrix4fv(viewUni, 1, false, view.caddr)
  glUniformMatrix4fv(projUni, 1, false, proj.caddr)

  glBindVertexArray(obj.vao)
  glDrawArrays(GL_TRIANGLES, 0, 36)

let shinyRender = proc(obj: Object): void =
  glBindFramebuffer(GL_FRAMEBUFFER, framebuffer[0])
  shinyRenderCore(obj)

let groundRender = proc(obj: Object): void =
  glEnable(GL_STENCIL_TEST)
  glStencilFunc(GL_ALWAYS, 1, 0xFF)
  glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE)
  glStencilMask(0xFF)
  glDepthMask(false)
  glClear(GL_STENCIL_BUFFER_BIT)

  glDrawArrays(GL_TRIANGLES, 36, 6)

let refshinyRender = proc(obj: Object): void =
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

let shinyFromAbove = proc(obj: Object): void =
  glBindFramebuffer(GL_FRAMEBUFFER, framebuffer[1])
  view = lookAt(vec3f(2.0, 0.0, -5.0), vec3f(0.0), vec3f(-1.0, 0.0, 0.0))
  shinyRenderCore(obj)
  groundRender(obj)
  refshinyRender(obj)
  view = lookAt(vec3f(2.5), vec3f(0.0), vec3f(0.0, 0.0, 1.0))

let sqwareRender = proc(obj: Object): void =
  glBindFramebuffer(GL_FRAMEBUFFER, 0)
  glUseProgram(sp2)
  glClearColor(0.2, 0.2, 0.2, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)
  glBindVertexArray(obj.vao)
  glUniform1i(glGetUniformLocation(sp2, "scene"), 2)
  glUniform1f(glGetUniformLocation(sp2, "xoffset"), -0.5'f32)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)
  glUniform1i(glGetUniformLocation(sp2, "scene"), 3)
  glUniform1f(glGetUniformLocation(sp2, "xoffset"), 0.5'f32)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)

discard ngn.addRender("shiny", shinyRender)
discard ngn.addRender("shiny", groundRender)
discard ngn.addRender("shiny", refshinyRender)
discard ngn.addRender("shiny", shinyFromAbove)
discard ngn.addRender("sqware", sqwareRender)

# add updates
let shinyUpdate = proc(delta: GLfloat): void =
  model = mat4f(1.0).rotate(glfwGetTime(), vec3f(0.0, 0.0, 1.0))

ngn.addUpdate(shinyUpdate)

ngn.loopEngine()
discard ngn.stopEngine()
