type
  Elf64Addr   = uint64
  Elf64Off    = uint64
  Elf64Half   = uint16
  Elf64Word   = uint32
  Elf64SWord  = int32
  Elf64XWord  = uint64
  Elf64SXWord = int64

  Elf64Ehdr* = object
    ident: array[0..15,uint8]
    `type`: Elf64Half
    machine: Elf64Half
    version: Elf64Word
    entry: Elf64Addr
    phoff*, shoff: Elf64Off
    flags: Elf64Word
    ehsize: Elf64Half
    phentsize, phnum*: Elf64Half
    shentsize, shnum: Elf64Half
    shstrndx: Elf64Half

  Elf64Phdr* = object
    `type`*: Elf64Word
    flags: Elf64Word
    offset*: Elf64Off
    vaddr*, paddr: Elf64Addr
    filesz*, memsz*: Elf64XWord
    align: Elf64XWord

  Elf64DynPtr {.union.} = object
    val: Elf64XWord
    p: Elf64Addr

  Elf64Dyn = object
    tag: Elf64SXWord
    un: Elf64DynPtr

  Elf64Rela = object
    offset: Elf64Addr
    info: Elf64XWord
    addend: Elf64SXWord

const ptLoad* = 1'u32
