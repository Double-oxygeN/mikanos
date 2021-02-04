from strutils import Newlines, join
import pixelwriter, fonts

const
  rows = 25
  columns = 80

type
  Console* = ref object
    writer: PixelWriter
    fgColor, bgColor: PixelColor
    buffer: array[rows, array[succ(columns), char]]
    cursorRow, cursorColumn: int

proc newConsole*(writer: PixelWriter; fgColor, bgColor: PixelColor): Console =
  Console(writer: writer, fgColor: fgColor, bgColor: bgColor)

proc newline(console: Console) =
  console.cursorColumn = 0

  if console.cursorRow < pred(rows):
    inc console.cursorRow

  else:
    for y in 0..<16 * rows:
      for x in 0..<8 * columns:
        console.writer.write(x, y, console.bgColor)

    for r in 0..<pred(rows):
      copyMem(addr console.buffer[r][0], addr console.buffer[succ(r)][0], columns + 1)
      console.writer.writeString(0, 16 * r, console.buffer[r].join(), console.fgColor)

    zeroMem(addr console.buffer[pred(rows)], succ(columns))

proc putString*(console: Console; str: string) =
  for c in str:
    case c
    of NewLines:
      console.newline()

    elif console.cursorColumn < columns - 1:
      console.writer.writeAscii(8 * console.cursorColumn, 16 * console.cursorRow, c, console.fgColor)
      console.buffer[console.cursorRow][console.cursorColumn] = c
      inc console.cursorColumn
