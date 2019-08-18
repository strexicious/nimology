from math import sin

import result
import glm
import nimgl/[glfw, opengl, stb/image]
import engine

const
  WIDTH = 800
  HEIGHT = 600

let engineErrorMapper = proc(x: string): string = "Engine error: " & x

var ngn = startEngine(WIDTH, HEIGHT, 0.2, 0.25, 0.2)
  .mapErr(engineErrorMapper)
  .get()
ngn.setCenteredPos()
ngn.setCursor(glfwCreateStandardCursor(csCrosshair))

# shader
var vertex_source: cstring = readFile("res/shaders/shader2.vert")
var fragment_source: cstring = readFile("res/shaders/shader2.frag")

let sp = ngn
  .regularShader(vertex_source, fragment_source)
  .mapErr(engineErrorMapper)
  .get()

# add renders with all the data
var data: seq[GLfloat] = @[]
for y in countup(0, 999):
  for x in countup(0, 1000):
    data.add((GLfloat(x) - 500.0) * 0.01)
    data.add((GLfloat(y) - 500.0) * 0.01)
    
    data.add((GLfloat(x) - 500.0) * 0.01)
    data.add((GLfloat(y+1) - 500.0) * 0.01)

discard ngn.addRawObject("sqware", data, @[(2'i32, 0)])

# add renders with all the data
let timeUni = glGetUniformLocation(sp, "time")
let viewUni = glGetUniformLocation(sp, "view")
let projUni = glGetUniformLocation(sp, "proj")

var viewDirAngle = 90.0'f32
var camPos = vec3f(0.0, 0.0, 10.0)

proc viewDir(angle: float32): Vec3f =
  return vec3f(cos(radians(angle)), 0.0, -sin(radians(angle)))

var view = lookAt(camPos, camPos + viewDir(viewDirAngle), vec3f(0.0, 1.0, 0.0))
var proj = perspective(GLfloat(45.0), WIDTH / HEIGHT, 1.0, 200.0)

var time: GLfloat = 0.0

let sqwareRender = proc(obj: Object): void =
  glUseProgram(sp)
  
  glUniform1f(timeUni, time)
  glUniformMatrix4fv(viewUni, 1, false, view.caddr)
  glUniformMatrix4fv(projUni, 1, false, proj.caddr)
  
  glBindVertexArray(obj.vao)
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 2 * 1000 * 1000)

discard ngn.addRender("sqware", sqwareRender)

# add updates
const moveSpeed: GLfloat = 0.3

let sqwareUpdate = proc(delta: GLfloat): void =
  time += delta

  let (x, _) = ngn.getCenteredPos()
  viewDirAngle -= x

  if ngn.window.getKey(keyW) == kaPress:
    camPos += moveSpeed * viewDir(viewDirAngle)

  if ngn.window.getKey(keyS) == kaPress:
    camPos -= moveSpeed * viewDir(viewDirAngle)
  
  let sideDir = cross(viewDir(viewDirAngle), vec3f(0.0, 1.0, 0.0))

  if ngn.window.getKey(keyA) == kaPress:
    camPos -= moveSpeed * sideDir

  if ngn.window.getKey(keyD) == kaPress:
    camPos += moveSpeed * sideDir
  
  view = lookAt(camPos, camPos + viewDir(viewDirAngle), vec3f(0.0, 1.0, 0.0))
  ngn.setCenteredPos()

ngn.addUpdate(sqwareUpdate)

ngn.loopEngine()
discard ngn.stopEngine()
