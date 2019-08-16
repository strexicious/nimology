from math import sin

import result
import nimgl/[glfw, opengl, stb/image]
import engine

let engineErrorMapper = proc(x: string): string = "Engine error: " & x

var ngn = startEngine(800, 600, 0.54, 0.41, 0.06)
  .mapErr(engineErrorMapper)
  .get()

var vertex_source: cstring = readFile("res/shaders/shader1.vert")
var fragment_source: cstring = readFile("res/shaders/shader1.frag")

let sp = ngn
  .regularShader(vertex_source, fragment_source)
  .mapErr(engineErrorMapper)
  .get()

glUseProgram(sp)

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

let imgData1 = stbiLoad("res/sample.png", stbiRGB)
ngn.addTexture(GL_TEXTURE0, imgData1)
imageFree(imgData1)

ngn.loopEngine()
discard ngn.stopEngine()
