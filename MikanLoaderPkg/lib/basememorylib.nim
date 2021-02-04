proc copyMem*(destinationBuffer, sourceBuffer: pointer; length: uint64): pointer {.importc: "CopyMem", header: "<Library/BaseMemoryLib.h>", nodecl.}
proc setMem*(buffer: pointer; length: uint64; value: uint8): pointer {.importc: "SetMem", header: "<Library/BaseMemoryLib.h>", nodecl.}
