from math import sin

import result
import glm
import nimgl/[glfw, opengl, stb/image]
import engine

let engineErrorMapper = proc(x: string): string = "Engine error: " & x

var ngn = startEngine(800, 600, 0.2, 0.2, 0.2)
  .mapErr(engineErrorMapper)
  .get()

glEnable(GL_RASTERIZER_DISCARD)

# shader
var vsource: cstring = readFile("res/shaders/shader1.vert")
let vshader = glCreateShader(GL_VERTEX_SHADER)
glShaderSource(vshader, 1, vsource.addr, nil)
glCompileShader(vshader)

var gsource: cstring = readFile("res/shaders/shader1.geom")
let gshader = glCreateShader(GL_GEOMETRY_SHADER)
glShaderSource(gshader, 1, gsource.addr, nil)
glCompileShader(gshader)

let program = glCreateProgram()
glAttachShader(program, vshader)
glAttachShader(program, gshader)
var feedbackVaryings: cstring = "ovalue"
glTransformFeedbackVaryings(program, 1, feedbackVaryings.addr, GL_INTERLEAVED_ATTRIBS)
glLinkProgram(program)
glUseProgram(program)

# vertex data
var data: array[5, GLfloat] = [1.0'f32, 2.0'f32, 3.0'f32, 4.0'f32, 5.0'f32]

var
  vao: GLuint
  vbo: GLuint
  tbo: GLuint
  query: GLuint

glGenQueries(1, query.addr)

glGenVertexArrays(1, vao.addr)
glBindVertexArray(vao)

glGenBuffers(1, vbo.addr)
glBindBuffer(GL_ARRAY_BUFFER, vbo)
glBufferData(GL_ARRAY_BUFFER, cast[GLsizeiptr](GLfloat.sizeof * data.len), data.addr, GL_STATIC_DRAW)

glEnableVertexAttribArray(0)
glVertexAttribPointer(0, 1, EGL_FLOAT, false, 0, nil)

glGenBuffers(1, tbo.addr)
glBindBuffer(GL_ARRAY_BUFFER, tbo)
glBufferData(GL_ARRAY_BUFFER, cast[GLsizeiptr](GLfloat.sizeof * data.len * 3), nil, GL_STATIC_READ)
glBindBUfferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, tbo)

glBeginQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, query)
glBeginTransformFeedback(GL_TRIANGLES)
glDrawArrays(GL_POINTS, 0, 5)
glEndTransformFeedback()
glEndQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN)
glFlush()

var primitives: GLint
glGetQueryObjectiv(query, GL_QUERY_RESULT, primitives.addr)

var fedback: seq[GLfloat]
fedback.setLen(primitives * 3)
glGetBufferSubData(GL_TRANSFORM_FEEDBACK_BUFFER, 0, cast[GLsizeiptr](GLfloat.sizeof * fedback.len), fedback[0].addr)

for f in fedback:
  echo f

discard ngn.stopEngine()
