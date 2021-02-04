{.compile: "newlib_support.c".}

proc kernelMain {.cdecl, exportc.} =
  while true:
    asm "hlt"
