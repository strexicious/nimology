from math import sin

import result
import glm
import nimgl/[glfw, opengl, stb/image]
import engine

let engineErrorMapper = proc(x: string): string = "Engine error: " & x

var ngn = startEngine(800, 600, 0.2, 0.2, 0.2)
  .mapErr(engineErrorMapper)
  .get()

ngn.loopEngine()

ngn.stopEngine()
  .mapErr(engineErrorMapper)
  .get()
