type
  PixelFormat* {.pure.} = enum
    pixelRGBResv8BitPerColor
    pixelBGRResv8BitPerColor

  FrameBufferConfig* {.exportc.} = object
    frameBuffer*: ptr UncheckedArray[uint8]
    pixelsPerScanLine*: uint32
    horizontalResolution*, verticalResolution*: uint32
    pixelFormat*: PixelFormat

  PixelColor* = tuple
    r, g, b: uint8


proc writePixel*(config: FrameBufferConfig; x, y: int; c: PixelColor) =
  let pixelPosition = int(config.pixelsPerScanLine) * y + x

  case config.pixelFormat
  of PixelFormat.pixelRGBResv8BitPerColor:
    config.frameBuffer[4 * pixelPosition] = c.r
    config.frameBuffer[4 * pixelPosition + 1] = c.g
    config.frameBuffer[4 * pixelPosition + 2] = c.b

  of PixelFormat.pixelBGRResv8BitPerColor:
    config.frameBuffer[4 * pixelPosition] = c.b
    config.frameBuffer[4 * pixelPosition + 1] = c.g
    config.frameBuffer[4 * pixelPosition + 2] = c.r
