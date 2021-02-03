import uefi

type
  EfiSimpleFileSystemProtocol* {.importc: "EFI_SIMPLE_FILE_SYSTEM_PROTOCOL", header: "<Protocol/SimpleFileSystem.h>", incompleteStruct.} = object

  EfiFileProtocol* {.importc: "EFI_FILE_PROTOCOL", header: "<Protocol/SimpleFileSystem.h>", incompleteStruct.} = object

var
  gEfiSimpleFileSystemProtocolGuid* {.importc, header: "<Protocol/SimpleFileSystem.h>", nodecl.}: EfiGuid


type
  OpenMode* = distinct uint64

const
  efiFileModeRead* = OpenMode(0x0000_0000_0000_0001'u64)


proc openVolume*(self: EfiSimpleFileSystemProtocol; this: ptr EfiSimpleFileSystemProtocol; root: ptr ptr EfiFileProtocol): EfiStatus {.importcpp: "OpenVolume".}

proc open*(self: EfiFileProtocol; this: ptr EfiFileProtocol; newHandle: ptr ptr EfiFileProtocol; fileName: WideString; openMode: OpenMode; attributes: uint64): EfiStatus {.importcpp: "Open".}
proc getInfo*(self: EfiFileProtocol; this: ptr EfiFileProtocol; informationType: ptr EfiGuid; bufferSize: ptr uint64; buffer: pointer): EfiStatus {.importcpp: "GetInfo".}
proc read*(self: EfiFileProtocol; this: ptr EfiFileProtocol; bufferSize: ptr uint64; buffer: pointer): EfiStatus {.importcpp: "Read".}
