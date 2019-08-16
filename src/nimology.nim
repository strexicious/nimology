from math import sin

import result
import glm
import nimgl/[glfw, opengl, stb/image]
import engine

let engineErrorMapper = proc(x: string): string = "Engine error: " & x

var ngn = startEngine(800, 600, 0.2, 0.25, 0.2)
  .mapErr(engineErrorMapper)
  .get()

# shader
var vertex_source: cstring = readFile("res/shaders/shader2.vert")
var fragment_source: cstring = readFile("res/shaders/shader2.frag")

let sp = ngn
  .regularShader(vertex_source, fragment_source)
  .mapErr(engineErrorMapper)
  .get()

# vertex data
var data: seq[GLfloat] = @[]
for z in countup(0, 1000):
  for x in countup(0, 1000):
    data.add((GLfloat(x) - 500.0) * 0.01)
    data.add((GLfloat(z) - 500.0) * 0.01)

discard ngn.addRawObject("sqware", data, @[(2'i32, 0)])

# add renders with all the data
var view = lookAt(vec3f(6.0), vec3f(0.0), vec3f(0.0, 1.0, 0.0))
var proj = ortho(-8.0'f32, 8.0'f32, -8.0'f32, 8.0'f32, 0.0'f32, 18.0'f32)

var time: GLfloat = 0.0

let sqwareRender = proc(): void =
  glUseProgram(sp)
  
  let viewUni = glGetUniformLocation(sp, "view")
  glUniformMatrix4fv(viewUni, 1, false, view.caddr)

  let projUni = glGetUniformLocation(sp, "proj")
  glUniformMatrix4fv(projUni, 1, false, proj.caddr)

  let timeUni = glGetUniformLocation(sp, "time")
  glUniform1fv(timeUni, 1, time.addr)

discard ngn.addRender("sqware", sqwareRender)

# add updates
let sqwareUpdate = proc(delta: GLfloat): void =
  time += delta

ngn.addUpdate(sqwareUpdate)

ngn.loopEngine()
discard ngn.stopEngine()
