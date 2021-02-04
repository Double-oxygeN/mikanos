{.compile: "newlib_support.c".}

import strformat
import common/framebufferconfig
import graphics/[pixelwriter, console, images]
import devices/pci
import util/error

proc kernelMain(pconfig: ptr FrameBufferConfig) {.cdecl, exportc.} =
  const
    white = (0xff'u8, 0xff'u8, 0xff'u8, false)
    gray9 = (0x21'u8, 0x25'u8, 0x29'u8, false)
  let
    config = pconfig[]
    pixelWriter = newPixelWriter(config)
    console = newConsole(pixelWriter, white, gray9)

  for y in low(backgroundImage)..high(backgroundImage):
    for x in low(backgroundImage[y])..high(backgroundImage[y]):
      pixelWriter.write(x, y, backgroundImage[y][x])

  for dy in low(mouseCursor)..high(mouseCursor):
    for dx in low(mouseCursor[dy])..high(mouseCursor[dy]):
      pixelWriter.write(200 + dx, 100 + dy, mouseCursor[dy][dx])

  let err = scanAllBus()
  console.putString &"ScanAllBus: {$err}\n"

  for i in 0..<numDevice:
    let
      dev = pci.devices[i]
      vendorId = readVendorId(dev.bus, dev.device, dev.function)
      classCode = readClassCode(dev.bus, dev.device, dev.function)

    console.putString &"{dev.bus}.{dev.device}.{dev.function}: vend {vendorId:04x}, class {classCode:08x}, head {dev.headerType:02x}\n"

  while true:
    asm "hlt"
