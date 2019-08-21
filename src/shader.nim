from strutils import spaces
import result
import nimgl/opengl

proc getShaderLog(s: GLuint): cstring =
  var logLength: GLsizei
  glGetShaderiv(s, GL_INFO_LOG_LENGTH, logLength.addr)
  
  result = spaces(logLength)
  glGetShaderInfoLog(s, logLength, nil, result)

proc createShaderProgram*(vsource: var cstring, fsource: var cstring): Result[GLuint, string] =
  let vshader = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(vshader, 1, vsource.addr, nil)
  glCompileShader(vshader)

  let fshader = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(fshader, 1, fsource.addr, nil)
  glCompileShader(fshader)

  var status: GLenum
  glGetShaderiv(vshader, GL_COMPILE_STATUS, cast[ptr GLint](status.addr))
  if status == GL_FALSE:
    result.err("Vertex shader error: " & $getShaderLog(vshader))
    return

  glGetShaderiv(fshader, GL_COMPILE_STATUS, cast[ptr GLint](status.addr))
  if status == GL_FALSE:
    result.err("Fragment shader error: " & $getShaderLog(fshader))
    return
  
  let program = glCreateProgram()
  glAttachShader(program, vshader)
  glAttachShader(program, fshader)
  glLinkProgram(program)
  glDetachShader(program, vshader)
  glDetachShader(program, fshader)
  glDeleteShader(vshader)
  glDeleteShader(fshader)

  result.ok(program)

proc createShaderProgram*(vsource, gsource, fsource: var cstring): Result[GLuint, string] =
  let vshader = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(vshader, 1, vsource.addr, nil)
  glCompileShader(vshader)

  let gshader = glCreateShader(GL_GEOMETRY_SHADER)
  glShaderSource(gshader, 1, gsource.addr, nil)
  glCompileShader(gshader)

  let fshader = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(fshader, 1, fsource.addr, nil)
  glCompileShader(fshader)

  var status: GLenum
  glGetShaderiv(vshader, GL_COMPILE_STATUS, cast[ptr GLint](status.addr))
  if status == GL_FALSE:
    result.err("Vertex shader error: " & $getShaderLog(vshader))
    return
  
  glGetShaderiv(gshader, GL_COMPILE_STATUS, cast[ptr GLint](status.addr))
  if status == GL_FALSE:
    result.err("Geometry shader error: " & $getShaderLog(gshader))
    return

  glGetShaderiv(fshader, GL_COMPILE_STATUS, cast[ptr GLint](status.addr))
  if status == GL_FALSE:
    result.err("Fragment shader error: " & $getShaderLog(fshader))
    return
  
  let program = glCreateProgram()
  glAttachShader(program, vshader)
  glAttachShader(program, gshader)
  glAttachShader(program, fshader)
  glLinkProgram(program)
  glDetachShader(program, vshader)
  glDetachShader(program, gshader)
  glDetachShader(program, fshader)
  glDeleteShader(vshader)
  glDeleteShader(gshader)
  glDeleteShader(fshader)

  result.ok(program)
