switch("noLinking")
switch("nimcache", "c")

switch("noMain")

switch("os", "any")
switch("d", "standaloneHeapSize=1048576")
switch("gc", "orc")
# switch("d", "nimNoLibc")

switch("checks", "off")
switch("assertions", "off")
switch("stackTrace", "off")

switch("cc", "clang")
switch("passC", "-Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone")
switch("passL", "--static")
