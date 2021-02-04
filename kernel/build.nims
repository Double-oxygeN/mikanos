import os, strformat

let
  osBookRoot = getEnv("OSBOOK_ROOTDIR", getHomeDir() / "osbook")
  includePath = osBookRoot / "devenv/x86_64-elf/include"
  libPath = osBookRoot / "devenv/x86_64-elf/lib"

task build, "Build kernel program":
  echo fmt"OS Book root path: {osBookRoot}"
  exec fmt"nim c --passC:'-I{includePath}' main"
  exec "nasm -f elf64 -o c/asmfunc.o asmfunc.asm"
  exec fmt"ld.lld --entry kernelMain -z norelro --image-base 0x100000 --static -o kernel.elf -L {libPath} -lc c/*.o"
