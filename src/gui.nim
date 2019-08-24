import nimgl/[opengl, stb/image]
import renderer/text
import command

type
  Gui* = object
    width: int32
    height: int32
    tr: TextRenderer
    info*: GuiInfo
  
  GuiInfo* = ref object
    color: array[3, GLfloat]
    fps: uint16
    ch: CommandHandler

proc newGui*(width, height: int32, info: GuiInfo, tr: var TextRenderer): Gui =
  tr.setCharSize(0.05)
  tr.setFontColor(1.0, 1.0, 1.0)
  return Gui(width: width, height: height, info: info, tr: tr)

proc drawGui*(gui: var Gui): void =
  gui.tr.emptyData()
  
  for i, c in "fps:" & $gui.info.fps:
    gui.tr.writeSymbolAt(getSymbol(c), -0.95 + GLfloat(i) * 0.05, 0.95, 0.0)
    
  for i, c in gui.info.ch.currCmd:
    gui.tr.writeSymbolAt(getSymbol(c), -0.98 + GLfloat(i) * 0.05, -0.85, 0.0)
    
  gui.tr.uploadData()
  gui.tr.render()

proc newGuiInfo*(color: array[3, GLfloat], ch: CommandHandler): GuiInfo =
  new result
  result.color = color
  result.ch = ch

proc setFps*(info: var GuiInfo, fps: uint16): void =
  info.fps = fps
