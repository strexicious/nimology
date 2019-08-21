import result
import nimgl/[opengl, stb/image]
import ../shader

type
  TextRenderer* = ref object
    data: seq[TextPoint]
    textPointsLen: GLsizei
    vao: GLuint
    vbo: GLuint
    unit: GLint
    fontTex: GLuint
    sprogram: GLuint

  TextPoint {.packed.} = object
    x: GLfloat
    y: GLfloat
    z: GLfloat
    symbol: GLuint

proc newTextRenderer*(font: string): TextRenderer =
  new result
  var
    vsource: cstring = readFile("res/shaders/text.vert")
    gsource: cstring = readFile("res/shaders/text.geom")
    fsource: cstring = readFile("res/shaders/text.frag")
  result.sprogram = createShaderProgram(vsource, gsource, fsource).get()

  glGenVertexArrays(1, result.vao.addr)
  glBindVertexArray(result.vao)
  glGenBuffers(1, result.vbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)

  let stride: GLsizei = GLfloat.sizeof * 3 + GLuint.sizeof
  let symbolOffset = GLfloat.sizeof * 3
  glVertexAttribPointer(0, 3, EGL_FLOAT, false, stride, nil)
  glVertexAttribIPointer(1, 1, GL_UNSIGNED_INT, stride, cast[pointer](symbolOffset))
  glEnableVertexAttribArray(0)
  glEnableVertexAttribArray(1)
  
  let imgData = stbiLoad(font, stbiRGB)
  
  glActiveTexture(GL_TEXTURE0)
  result.unit = 0
  glGenTextures(1, result.fontTex.addr)

  glBindTexture(GL_TEXTURE_RECTANGLE, result.fontTex)
  glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MIN_FILTER, GLint(GL_NEAREST))
  glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MAG_FILTER, GLint(GL_NEAREST))
  glTexImage2D(GL_TEXTURE_RECTANGLE, 0, GLint(GL_RGB), imgData.width, imgData.height, 0, GL_RGB,
    GL_UNSIGNED_BYTE, cast[pointer](imgData.data))
  
  imgData.imageFree()

proc setCharSize*(tr: var TextRenderer, cs: GLfloat): void =
  glUseProgram(tr.sprogram)
  glUniform1f(0, cs)

proc setFontColor*(tr: var TextRenderer, r, g, b: GLfloat): void =
  glUseProgram(tr.sprogram)
  glUniform3f(2, r, g, b)

proc writeSymbolAt*(tr: var TextRenderer, symbol: GLuint, x, y, z: GLfloat): void =
  tr.data.add(TextPoint(x: x, y: y, z: z, symbol: symbol)) 

proc emptyData*(tr: var TextRenderer): void =
  tr.data = @[]

proc uploadData*(tr: var TextRenderer): void =
  glBindBuffer(GL_ARRAY_BUFFER, tr.vbo)
  glBufferData(GL_ARRAY_BUFFER, tr.data.len * TextPoint.sizeof, tr.data[0].addr, GL_STATIC_DRAW)
  tr.textPointsLen = GLsizei(tr.data.len)
  tr.emptyData()

proc render*(tr: TextRenderer): void =
  glUseProgram(tr.sprogram)
  glBindVertexArray(tr.vao)
  glDrawArrays(GL_POINTS, 0, tr.textPointsLen)

proc cleanTextRenderer*(tr: var TextRenderer): void =
  glDeleteTextures(1, tr.fontTex.addr)
  glDeleteBuffers(1, tr.vbo.addr)
  glDeleteVertexArrays(1, tr.vao.addr)
  glDeleteProgram(tr.sprogram)

proc getSymbol*(c: char): GLuint =
  return GLuint(ord(c) - ord('a'))
