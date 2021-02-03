import uefi

type
  EfiTime* {.importc: "EFI_TIME", header: "<Guid/FileInfo.h>", completeStruct.} = object
    year: uint16
    month, day, hour, minute, second, pad1: uint8
    nanosecond: uint32
    timezone: int16
    daylight: uint8
    pad2: uint8

  EfiFileInfo* {.importc: "EFI_FILE_INFO", header: "<Guid/FileInfo.h>", completeStruct.} = object
    size, fileSize* {.importc: "FileSize".}, physicalSize: uint64
    createTime, lastAccessTime, modificationTime: EfiTime
    attribute: uint64
    fileName: array[1, uint16]

var
  gEfiFileInfoGuid* {.importc, header: "<Guid/FileInfo.h>", nodecl.}: EfiGuid
