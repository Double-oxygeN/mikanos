import uefi

type
  EfiBootServices* {.importc: "EFI_BOOT_SERVICES", header: "<Library/UefiBootServicesTableLib.h>", incompleteStruct.} = object

  EfiAllocateType* {.importc: "EFI_ALLOCATE_TYPE", header: "<Library/UefiBootServicesTableLib.h>".} = enum
    AllocateAnyPages
    AllocateMaxAddress
    AllocateAddress
    MaxAllocateType

  EfiMemoryType* {.importc: "EFI_MEMORY_TYPE", header: "<Library/UefiBootServicesTableLib.h>".} = enum
    EfiReservedMemoryType
    EfiLoaderCode
    EfiLoaderData
    EfiBootServicesCode
    EfiBootServicesData
    EfiRuntimeServicesCode
    EfiRuntimeServicesData
    EfiConventionalMemory
    EfiUnusableMemory
    EfiACPIReclaimMemory
    EfiACPIMemoryNVS
    EfiMemoryMappedIO
    EfiMemoryMappedIOPortSpace
    EfiPalCode
    EfiPersistentMemory
    EfiMaxMemoryType

  EfiMemoryDescriptor* {.importc: "EFI_MEMORY_DESCRIPTOR", header: "<Library/UefiBootServicesTableLib.h>", incompleteStruct.} = object

let
  gBS* {.importc, header: "<Library/UefiBootServicesTableLib.h>", nodecl.}: ptr EfiBootServices


proc openProtocol*(self: EfiBootServices; handle: EfiHandle; protocol: ptr EfiGuid; `interface`: ptr pointer; agentHandle, controllerHandle: EfiHandle; attributes: uint32): EfiStatus {.importcpp: "OpenProtocol".}
proc allocatePages*(self: EfiBootServices; `type`: EfiAllocateType; memoryType: EfiMemoryType; pages: uint64; memory: ptr EfiPhysicalAddress): EfiStatus {.importcpp: "AllocatePages".}
proc exitBootServices*(self: EfiBootServices; imageHandle: EfiHandle; mapkey: uint64): EfiStatus {.importcpp: "ExitBootServices".}
proc getMemoryMap*(self: EfiBootServices; memoryMapSize: ptr uint64; memoryMap: ptr EfiMemoryDescriptor; mapKey, descriptorSize: ptr uint64; descriptorVersion: ptr uint32): EfiStatus {.importcpp: "GetMemoryMap".}
