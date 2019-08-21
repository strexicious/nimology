import nimgl/[opengl, stb/image]
import renderer/text

type
  Gui* = object
    width: int32
    height: int32
    tr: TextRenderer
    info*: GuiInfo
  
  GuiInfo* = ref object
    color: array[3, GLfloat]
    fps: uint16

proc newGui*(width, height: int32, info: GuiInfo, tr: var TextRenderer): Gui =
  for i, c in "strexicious":
    tr.writeSymbolAt(getSymbol(c), -0.55 + GLfloat(i) * 0.1, 0.0, 0.0)
  tr.uploadData()
  tr.setCharSize(0.1)
  tr.setFontColor(1.0, 1.0, 1.0)
  return Gui(width: width, height: height, info: info, tr: tr)

proc drawGui*(gui: var Gui): void =
  gui.tr.render()

proc newGuiInfo*(color: array[3, GLfloat]): GuiInfo =
  new result
  result.color = color

proc setFps*(info: var GuiInfo, fps: uint16): void =
  info.fps = fps
