import macros
import uefi

proc print*(format: WideString) {.importc: "Print", header: "<Library/UefiLib.h>", varargs, cdecl.}

macro fastwidestr*(strlit: string{lit}): untyped =
  let arr = nnkBracket.newNimNode()

  for c in $strlit:
    arr.add newLit(uint16(c))

  arr.add newLit(0'u16)

  result = quote do:
    (var tmp = `arr`; addr tmp[0]).WideString
