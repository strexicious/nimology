import result
import glm
import nimgl/opengl
import ../shader
import ../camera

type
  ModelRenderer* = ref object
    vao: GLuint
    vbo: GLuint
    sprogram: GLuint
    data: seq[GLfloat]
    cam*: Camera

proc newModelRenderer*(width: int32, height: int32): ModelRenderer =
  new result
  var
    vsource: cstring = readFile("res/shaders/model.vert")
    fsource: cstring = readFile("res/shaders/model.frag")
  result.sprogram = createShaderProgram(vsource, fsource).get()
  glUseProgram(result.sprogram)

  result.cam = newCamera()
  var view = result.cam.viewMatrix()
  glUniformMatrix4fv(1, 1, false, view.caddr)

  var proj = perspective(radians(GLfloat(90.0)), width / height, 1.0, 100.0)
  glUniformMatrix4fv(0, 1, false, proj.caddr)

  glGenVertexArrays(1, result.vao.addr)
  glBindVertexArray(result.vao)
  glGenBuffers(1, result.vbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  glVertexAttribPointer(0, 3, EGL_FLOAT, false, 0, nil)
  glEnableVertexAttribArray(0)

  glEnable(GL_CULL_FACE)

proc emptyData*(mr: ModelRenderer): void =
  mr.data = @[]

proc addVertex*(mr: ModelRenderer, x, y, z: GLfloat): void =
  mr.data.add([x, y, z])

proc uploadData*(mr: ModelRenderer): void =
  glBindBuffer(GL_ARRAY_BUFFER, mr.vbo)
  glBufferData(GL_ARRAY_BUFFER, GLfloat.sizeof * mr.data.len, mr.data[0].addr, GL_STATIC_DRAW)

proc updateView*(mr: ModelRenderer): void =
  glUseProgram(mr.sprogram)
  var view = mr.cam.viewMatrix()
  glUniformMatrix4fv(1, 1, false, view.caddr)

proc render*(mr: ModelRenderer): void =
  glEnable(GL_DEPTH_TEST)
  glClear(GL_DEPTH_BUFFER_BIT)
  glUseProgram(mr.sprogram)
  glBindVertexArray(mr.vao)
  glDrawArrays(GL_TRIANGLES, 0, GLsizei(mr.data.len))
  glDisable(GL_DEPTH_TEST)

proc cleanModelRenderer*(mr: var ModelRenderer): void =
  glDeleteBuffers(1, mr.vbo.addr)
  glDeleteVertexArrays(1, mr.vao.addr)
  glDeleteProgram(mr.sprogram)
