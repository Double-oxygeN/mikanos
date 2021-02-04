import ../common/framebufferconfig

export PixelColor

type
  PixelWriter* = ref object
    config: FrameBufferConfig
    writeMethod: (proc (config: FrameBufferConfig; position: int; c: PixelColor))

proc write*(self: PixelWriter; x, y: int; c: PixelColor) =
  let position = int(self.config.pixelsPerScanLine) * y + x
  self.writeMethod(self.config, position, c)

proc writeRGBResv8BitPerColor(config: FrameBufferConfig; position: int; c: PixelColor) =
  config.frameBuffer[4 * position] = c.r
  config.frameBuffer[4 * position + 1] = c.g
  config.frameBuffer[4 * position + 2] = c.b

proc writeBGRResv8BitPerColor(config: FrameBufferConfig; position: int; c: PixelColor) =
  config.frameBuffer[4 * position] = c.b
  config.frameBuffer[4 * position + 1] = c.g
  config.frameBuffer[4 * position + 2] = c.r

proc newPixelWriter*(config: FrameBufferConfig): PixelWriter =
  new result
  result.config = config
  result.writeMethod = case config.pixelFormat
    of pixelRGBResv8BitPerColor: writeRGBResv8BitPerColor
    of pixelBGRResv8BitPerColor: writeBGRResv8BitPerColor
