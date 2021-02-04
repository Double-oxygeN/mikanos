{.compile: "newlib_support.c".}

import common/framebufferconfig

proc kernelMain(pconfig: ptr FrameBufferConfig) {.cdecl, exportc.} =
  let config = pconfig[]

  let white = (0xff'u8, 0xff'u8, 0xff'u8)
  for x in 0..<int(config.horizontalResolution):
    for y in 0..<int(config.verticalResolution):
      config.writePixel(x, y, white)

  let green6 = (0x40'u8, 0xc0'u8, 0x57'u8)
  for x in 0..<200:
    for y in 0..<100:
      config.writePixel(100 + x, 100 + y, green6)

  while true:
    asm "hlt"
