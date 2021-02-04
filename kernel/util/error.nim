type
  Error* {.pure.} = enum
    success
    full
    empty
    lastOfCode

converter toBool*(x: Error): bool = x != Error.success
