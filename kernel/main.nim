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

  for y in low(backgroundImage)..high(backgroundImage):
    for x in low(backgroundImage[y])..high(backgroundImage[y]):
      pixelWriter.write(x, y, backgroundImage[y][x])

  for dy in low(mouseCursor)..high(mouseCursor):
    for dx in low(mouseCursor[dy])..high(mouseCursor[dy]):
      pixelWriter.write(200 + dx, 100 + dy, mouseCursor[dy][dx])

  while true:
    asm "hlt"
