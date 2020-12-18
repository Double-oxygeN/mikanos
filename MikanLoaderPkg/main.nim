{.pragma: efidecl, cdecl, exportc, codegenDecl: "$# EFIAPI $#$#".}

type
  WideString {.importc: "CONST CHAR16 *", header: "<Uefi.h>".} = distinct ptr uint16

{.emit: "CONST CHAR16 *hello = u\"Hello, Mikan World!\\nNim Build Version\\n\";" .}

let hello {.importc, nodecl.}: WideString


type
  EfiStatus {.importc: "EFI_STATUS", header: "<Uefi.h>".} = uint64

  EfiHandle {.importc: "EFI_HANDLE", header: "<Uefi.h>".} = distinct pointer

  EfiSystemTable {.importc: "EFI_SYSTEM_TABLE", header: "<Uefi.h>".} = object


proc print(format: WideString) {.importc: "Print", header: "<Library/UefiLib.h>", varargs, cdecl.}


proc uefiMain(imageHandle: EfiHandle; systemTable: ptr EfiSystemTable): EfiStatus {.efidecl.} =
  print(hello)
  while true: discard
