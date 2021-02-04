switch("noLinking")
switch("nimcache", "c")

switch("noMain")

switch("os", "any")
switch("d", "standaloneHeapSize=33554432")
switch("gc", "orc")
# switch("d", "nimNoLibc")

switch("checks", "off")
switch("assertions", "off")
switch("stackTrace", "off")

switch("cc", "clang")
switch("passC", "-Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone -nostdlibinc -D__ELF__ -D_LDBL_EQ_DBL -D_GNU_SOURCE -D_POSIX_TIMERS")
