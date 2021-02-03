{.pragma: efidecl, cdecl, exportc, codegenDecl: "$# EFIAPI $#$#".}

import macros

type
  WideString {.importc: "CHAR16 *", header: "<Uefi.h>".} = distinct ptr uint16


macro fastwidestr(strlit: string{lit}): untyped =
  let arr = nnkBracket.newNimNode()

  for c in $strlit:
    arr.add newLit(uint16(c))

  arr.add newLit(0'u16)

  result = quote do:
    (var tmp = `arr`; addr tmp[0]).WideString


type
  EfiStatus {.importc: "EFI_STATUS", header: "<Uefi.h>".} = uint64

  EfiHandle {.importc: "EFI_HANDLE", header: "<Uefi.h>".} = distinct pointer

  EfiSystemTable {.importc: "EFI_SYSTEM_TABLE", header: "<Uefi.h>".} = object


proc print(format: WideString) {.importc: "Print", header: "<Library/UefiLib.h>", varargs, cdecl.}


proc uefiMain(imageHandle: EfiHandle; systemTable: ptr EfiSystemTable): EfiStatus {.efidecl.} =
  print fastwidestr"Hello, Mikan World!"
  while true: discard
