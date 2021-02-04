{.compile: "newlib_support.c".}

import common/framebufferconfig
import graphics/[pixelwriter, console, images]

proc kernelMain(pconfig: ptr FrameBufferConfig) {.cdecl, exportc.} =
  const
    white = (0xff'u8, 0xff'u8, 0xff'u8, false)
    gray9 = (0x21'u8, 0x25'u8, 0x29'u8, false)
  let
    config = pconfig[]
    pixelWriter = newPixelWriter(config)
    console = newConsole(pixelWriter, gray9, white)

  for x in 0..<int(config.horizontalResolution):
    for y in 0..<int(config.verticalResolution):
      pixelWriter.write(x, y, white)

  for dy in low(mouseCursor)..high(mouseCursor):
    for dx in low(mouseCursor[dy])..high(mouseCursor[dy]):
      pixelWriter.write(200 + dx, 100 + dy, mouseCursor[dy][dx])

  while true:
    asm "hlt"
