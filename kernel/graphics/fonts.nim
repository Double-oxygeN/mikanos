import pixelwriter

const kFontA = [
  0b00000000'u8,
  0b00011000'u8,
  0b00011000'u8,
  0b00011000'u8,
  0b00011000'u8,
  0b00100100'u8,
  0b00100100'u8,
  0b00100100'u8,
  0b00100100'u8,
  0b01111110'u8,
  0b01000010'u8,
  0b01000010'u8,
  0b01000010'u8,
  0b11100111'u8,
  0b00000000'u8,
  0b00000000'u8
]

proc writeAscii*(writer: PixelWriter; x, y: int; c: char; color: PixelColor) =
  if c != 'A': return

  for dy in 0..<16:
    for dx in 0..<8:
      if ((kFontA[dy] shl dx) and 0x80'u8) > 0'u8:
        writer.write(x + dx, y + dy, color)
