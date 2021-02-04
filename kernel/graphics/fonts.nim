import pixelwriter

proc createFont(bitmapFontFileName: string): array[char, array[0..15, uint8]] {.compileTime.} =
  let bitmapFontFile = slurp(bitmapFontFileName)

  for i, b in bitmapFontFile:
    let ch = char(i div 16)
    result[ch][i mod 16] = uint8(b)

const fonts = createFont("../hankaku.bin")

proc writeAscii*(writer: PixelWriter; x, y: int; c: char; color: PixelColor) =
  for dy in 0..<16:
    for dx in 0..<8:
      if ((fonts[c][dy] shl dx) and 0x80'u8) > 0'u8:
        writer.write(x + dx, y + dy, color)

proc writeString*(writer: PixelWriter; x, y: int; str: string; color: PixelColor) =
  for i, c in str:
    writer.writeAscii(x + 8 * i, y, c, color)
