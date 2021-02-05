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

  let errScanAllBus = scanAllBus()
  console.putString &"ScanAllBus: {$errScanAllBus}\n"

  for i in 0..<numDevice:
    let
      dev = pci.devices[i]
      vendorId = readVendorId(dev.bus, dev.device, dev.function)
      classCode = dev.classCode

    console.putString &"{dev.bus}.{dev.device}.{dev.function}: vend {vendorId:04x}, class {classCode.toU32():08x}, head {dev.headerType:02x}\n"

  # xHC デバイスの探索
  var xhcDev: ref Device = nil
  for i in 0..<numDevice:
    if pci.devices[i].classCode ~= (0x0c'u8, 0x03'u8, 0x30'u8):
      new xhcDev
      xhcDev[] = pci.devices[i]

      if 0x8086'u16 == readVendorId(xhcDev[]): break

  if not xhcDev.isNil:
    console.putString &"xHC has been found: {xhcDev.bus}.{xhcDev.device}.{xhcDev.function}\n"

  else:
    console.putString &"xHC device not found\n"
    while true:
      asm "hlt"

  # Base Address Register 0 から MM I/O アドレスを取得
  let (xhcBar, errReadBar) = readBar(xhcDev[], 0'u8)
  console.putString &"ReadBar: {$errReadBar}\n"
  let xhcMmioBase = xhcBar and not 0xf'u64
  console.putString &"xHC MM I/O base: {xhcMmioBase}\n"

  while true:
    asm "hlt"
