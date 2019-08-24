import strutils
import tables
import nimgl/glfw
import result

type
  CmdHandler* = proc(params: openarray[string]): void
  
  CommandHandler* = ref object
    history: seq[string]
    currCmd: string
    handlers: Table[string, CmdHandler]

proc currCmd*(ch: CommandHandler): string =
  return ch.currCmd

proc clearCurrCmd*(ch: CommandHandler): void =
  ch.currCmd = ""

proc registerHandler*(ch: CommandHandler, cmdName: string, handler: CmdHandler): void =
  ch.handlers[cmdName] = handler

proc handleInput*(
  ch: CommandHandler,
  key: GLFWKey,
  scancode: int32,
  action: GLFWKeyAction,
  mods: GLFWKeyMod
): void =
  if action != kaPress:
    return

  if key in keyA..keyZ:
    ch.currCmd.add(char(ord(key) - ord(keyA) + ord('a')))
    return
  
  if key == keyPeriod:
    ch.currCmd.add(".")
    return
  
  if key == key7 and mods == kmShift:
    ch.currCmd.add("/")
    return
  
  if key == keySpace:
    ch.currCmd.add(" ")
    return
  
  if key in key0..key9:
    ch.currCmd.add(char(ord(key) - ord(key0) + ord('0')))
    return
  
  if key == keyBackspace:
    ch.currCmd = ch.currCmd.substr(0, ch.currCmd.len - 2)
    return

  if key == keyEnter:
    let args = ch.currCmd.splitWhitespace()
    if ch.handlers.hasKey(args[0]):
      ch.handlers[args[0]](args[1..args.len-1])
    else:
      echo "No handler found for: ", args[0]
    ch.clearCurrCmd()
    return
