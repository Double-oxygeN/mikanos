{.compile: "newlib_support.c".}

import strformat
import common/framebufferconfig
import graphics/[pixelwriter, fonts]

proc kernelMain(pconfig: ptr FrameBufferConfig) {.cdecl, exportc.} =
  let
    config = pconfig[]
    pixelWriter = newPixelWriter(config)

  let white = (0xff'u8, 0xff'u8, 0xff'u8)
  for x in 0..<int(config.horizontalResolution):
    for y in 0..<int(config.verticalResolution):
      pixelWriter.write(x, y, white)

  let green6 = (0x40'u8, 0xc0'u8, 0x57'u8)
  for x in 0..<200:
    for y in 0..<100:
      pixelWriter.write(100 + x, 100 + y, green6)

  let gray9 = (0x21'u8, 0x25'u8, 0x29'u8)
  for c in '!'..'~':
    let i = int(c) - int('!')
    pixelWriter.writeAscii(8 * i, 50, c, gray9)

  pixelWriter.writeString(0, 66, "Hello, world!", gray9)
  pixelWriter.writeString(0, 82, fmt"1 + 2 = {1 + 2}", gray9)

  while true:
    asm "hlt"
