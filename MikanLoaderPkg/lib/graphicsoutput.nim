import uefi

type
  EfiGraphicsOutputProtocolMode* {.importc: "EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE", header: "<Library/UefiLib.h>", incompleteStruct.} = object
    frameBufferBase* {.importc: "FrameBufferBase".}: EfiPhysicalAddress
    frameBufferSize* {.importc: "FrameBufferSize".}: uint64

  EfiGraphicsOutputProtocol* {.importc: "EFI_GRAPHICS_OUTPUT_PROTOCOL", header: "<Library/UefiLib.h>", incompleteStruct.} = object
    mode* {.importc: "Mode".}: ptr EfiGraphicsOutputProtocolMode

var
  gEfiGraphicsOutputProtocolGuid* {.importc, header: "<Library/UefiLib.h>", nodecl.}: EfiGuid
