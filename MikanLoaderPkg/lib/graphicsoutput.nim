import uefi

type
  EfiGraphicsPixelFormat* {.importc: "EFI_GRAPHICS_PIXEL_FORMAT", header: "<Library/UefiLib.h>".} = enum
    PixelRedGreenBlueReserved8BitPerColor
    PixelBlueGreenRedReserved8BitPerColor
    PixelBitMask
    PixelBltOnly
    PixelFormatMax

  EfiGraphicsOutputModeInformation* {.importc: "EFI_GRAPHICS_OUTPUT_MODE_INFORMATION", header: "<Library/UefiLib.h>", incompleteStruct.} = object
    horizontalResolution* {.importc: "HorizontalResolution".}, verticalResolution* {.importc: "VerticalResolution".}: uint32
    pixelFormat* {.importc: "PixelFormat".}: EfiGraphicsPixelFormat
    pixelsPerScanLine* {.importc: "PixelsPerScanLine".}: uint32

  EfiGraphicsOutputProtocolMode* {.importc: "EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE", header: "<Library/UefiLib.h>", incompleteStruct.} = object
    info* {.importc: "Info".}: ptr EfiGraphicsOutputModeInformation
    frameBufferBase* {.importc: "FrameBufferBase".}: EfiPhysicalAddress
    frameBufferSize* {.importc: "FrameBufferSize".}: uint64

  EfiGraphicsOutputProtocol* {.importc: "EFI_GRAPHICS_OUTPUT_PROTOCOL", header: "<Library/UefiLib.h>", incompleteStruct.} = object
    mode* {.importc: "Mode".}: ptr EfiGraphicsOutputProtocolMode

var
  gEfiGraphicsOutputProtocolGuid* {.importc, header: "<Library/UefiLib.h>", nodecl.}: EfiGuid
