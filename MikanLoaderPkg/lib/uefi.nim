
type
  EfiStatus* {.importc: "EFI_STATUS", header: "<Uefi.h>".} = uint64
  EfiHandle* {.importc: "EFI_HANDLE", header: "<Uefi.h>".} = distinct pointer
  EfiSystemTable* {.importc: "EFI_SYSTEM_TABLE", header: "<Uefi.h>".} = object
