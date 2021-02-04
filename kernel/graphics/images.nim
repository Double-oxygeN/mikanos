import ../common/framebufferconfig

proc loadRawImage(rawImageFileName: string; width, height: static int): array[height, array[width, PixelColor]] {.compileTime.} =
  let rawImageData = slurp(rawImageFileName)

  for i, b in rawImageData:
    if (i shr 2) >= width * height: return
    case i mod 4
    of 0: result[(i shr 2) div width][(i shr 2) mod width].b = uint8(b)
    of 1: result[(i shr 2) div width][(i shr 2) mod width].g = uint8(b)
    of 2: result[(i shr 2) div width][(i shr 2) mod width].r = uint8(b)
    else: result[(i shr 2) div width][(i shr 2) mod width].transparent = uint8(b) < 0x80'u8


const mouseCursor* = loadRawImage("../cursor.raw", 15, 24)
