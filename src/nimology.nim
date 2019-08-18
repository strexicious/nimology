from math import sin

import result
import glm
import nimgl/[glfw, opengl, stb/image]
import engine

let engineErrorMapper = proc(x: string): string = "Engine error: " & x

var ngn = startEngine(800, 600, 0.2, 0.2, 0.2)
  .mapErr(engineErrorMapper)
  .get()

# shader
var vertex_source: cstring = readFile("res/shaders/shader1.vert")
var geometry_source: cstring = readFile("res/shaders/shader1.geom")
var fragment_source: cstring = readFile("res/shaders/shader1.frag")

let sp = ngn
  .regularShaderWithGS(vertex_source, geometry_source, fragment_source)
  .mapErr(engineErrorMapper)
  .get()
glUseProgram(sp)

# vertex data
var data: seq[GLfloat] =
 @[
    -0.45'f32,  0.45'f32, 1.0'f32, 0.0'f32, 0.0'f32,  4.0'f32,
     0.45'f32,  0.45'f32, 0.0'f32, 1.0'f32, 0.0'f32,  8.0'f32,
     0.45'f32, -0.45'f32, 0.0'f32, 0.0'f32, 1.0'f32, 16.0'f32,
    -0.45'f32, -0.45'f32, 1.0'f32, 1.0'f32, 0.0'f32, 32.0'f32,
  ]

discard ngn.addRawObject("pointa", data, @[(2'i32, 0), (3'i32, 2), (1'i32, 5)])

# add renders with all the data
let pointaRender = proc(obj: Object): void =
  glBindVertexArray(obj.vao)
  glDrawArrays(GL_POINTS, 0, 4)

discard ngn.addRender("pointa", pointaRender)

ngn.loopEngine()
discard ngn.stopEngine()
