import glm
import nimgl/[glfw, opengl]

const MOVE_SPEED: GLfloat = 0.1

type
  Camera* = ref object
    forward: Vec3f
    pos: Vec3f
  
  MoveDir* = enum
    md_backward = -1, md_forward = 1

proc newCamera*(): Camera =
  return Camera(pos: vec3f(0.0, 0.0, 5.0), forward: vec3f(0.0, 0.0, -1.0))

proc moveCamera*(cam: var Camera, md: MoveDir): void =
  cam.pos += cam.forward * MOVE_SPEED * float(md)

proc viewMatrix*(cam: Camera): Mat4[GLfloat] =
  return lookAt(cam.pos, cam.pos + cam.forward, vec3f(0.0, 1.0, 0.0))

proc setAngles*(cam: Camera, x: GLfloat, y: GLfloat): void =
  let cosY = cos(radians(y))
  let sinY = sin(radians(y))
  cam.forward = normalize(vec3f(sin(radians(x)) * cosY, -sinY, -cos(radians(x)) * cosY))
