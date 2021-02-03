import uefi

type
  EfiLoadedImageProtocol* {.importc: "EFI_LOADED_IMAGE_PROTOCOL", header: "<Protocol/LoadedImage.h>", incompleteStruct.} = object
    deviceHandle* {.importc: "DeviceHandle".}: EfiHandle

var
  gEfiLoadedImageProtocolGuid* {.importc, header: "<Protocol/LoadedImage.h>", nodecl.}: EfiGuid
