{.compile: "newlib_support.c".}

proc kernelMain(frameBufferBase, frameBufferSize: uint64) {.cdecl, exportc.} =
  var frameBuffer = cast[ptr UncheckedArray[uint8]](frameBufferBase)

  for i in 0..<frameBufferSize:
    frameBuffer[int(i)] = case int(i) mod 4
      of 0: 0xFF'u8
      of 1: 0xCC'u8
      of 2: 0x66'u8
      else: 0x00'u8

  while true:
    asm "hlt"
