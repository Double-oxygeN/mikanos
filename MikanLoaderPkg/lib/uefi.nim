type
  EfiStatus* {.importc: "EFI_STATUS", header: "<Uefi.h>".} = uint64
  EfiHandle* {.importc: "EFI_HANDLE", header: "<Uefi.h>".} = distinct pointer
  EfiSystemTable* {.importc: "EFI_SYSTEM_TABLE", header: "<Uefi.h>".} = object
  EfiGuid* {.importc: "EFI_GUID", header: "<Uefi.h>".} = object
    data1: uint32
    data2: uint16
    data3: uint16
    data4: array[0..7,uint8]

  EfiPhysicalAddress* {.importc: "EFI_PHYSICAL_ADDRESS", header: "<Uefi.h>".} = uint64

type
  WideString* {.importc: "CHAR16 *", header: "<Uefi.h>".} = distinct ptr uint16

const
  efiOpenProtocolByHandleProtocol* = 0x0000_0001'u32

const
  efiSuccess* = EfiStatus(0'u64)
  efiBufferTooSmall* = EfiStatus(5'u64)

proc efiError*(status: EfiStatus): bool {.importc: "EFI_ERROR", header: "<Uefi.h>", nodecl.}
