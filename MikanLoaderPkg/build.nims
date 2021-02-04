task build, "Build boot-loader program":
  exec "nim c main"
  exec "sed -i '2469d;2465d' c/stdlib_system.nim.c"
