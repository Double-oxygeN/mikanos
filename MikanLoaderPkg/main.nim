{.pragma: efidecl, cdecl, exportc, codegenDecl: "$# EFIAPI $#$#".}

import lib/[uefi, uefilib]

proc uefiMain(imageHandle: EfiHandle; systemTable: ptr EfiSystemTable): EfiStatus {.efidecl.} =
  print fastwidestr("Hello, Mikan World!\n")

  while true: discard
