{.pragma: efidecl, cdecl, exportc, codegenDecl: "$# EFIAPI $#$#".}

import lib/[
  uefi,
  uefilib,
  uefibootservicestablelib,
  memoryallocationlib,
  basememorylib,
  loadedimageprotocol,
  simplefilesystemprotocol,
  fileinfo,
  graphicsoutput,
  elf
]
import common/framebufferconfig

proc halt =
  while true:
    asm "hlt"

type
  MemoryMap = object
    bufferSize: culonglong
    buffer: pointer
    mapSize, mapKey, descriptorSize: culonglong
    descriptorVersion: uint32


proc getMemoryMap(map: var MemoryMap): EfiStatus =
  if map.buffer.isNil:
    return efiBufferTooSmall

  map.mapSize = map.bufferSize
  result = gBS[].getMemoryMap(
    addr map.mapSize,
    cast[ptr EfiMemoryDescriptor](map.buffer),
    addr map.mapKey,
    addr map.descriptorSize,
    addr map.descriptorVersion)

proc openRootDir(imageHandle: EfiHandle; root: var ptr EfiFileProtocol): EfiStatus =
  var
    loadedImage: ptr EfiLoadedImageProtocol
    fs: ptr EfiSimpleFileSystemProtocol

  result = gBS[].openProtocol(
    imageHandle,
    addr gEfiLoadedImageProtocolGuid,
    cast[ptr pointer](addr loadedImage),
    imageHandle,
    EfiHandle(nil),
    efiOpenProtocolByHandleProtocol)

  if efiError(result): return

  result = gBS[].openProtocol(
    loadedImage.deviceHandle,
    addr gEfiSimpleFileSystemProtocolGuid,
    cast[ptr pointer](addr fs),
    imageHandle,
    EfiHandle(nil),
    efiOpenProtocolByHandleProtocol)

  if efiError(result): return

  result = fs[].openVolume(fs, addr root)

proc openGop(imageHandle: EfiHandle; gop: var ptr EfiGraphicsOutputProtocol): EfiStatus =
  var
    numGopHandles: culonglong = 0'u64
    gopHandles: ptr EfiHandle = nil

  result = gBS[].locateHandleBuffer(
    ByProtocol,
    addr gEfiGraphicsOutputProtocolGuid,
    nil,
    addr numGopHandles,
    addr gopHandles)

  if efiError(result): return

  result = gBS[].openProtocol(
    gopHandles[],
    addr gEfiGraphicsOutputProtocolGuid,
    cast[ptr pointer](addr gop),
    imageHandle,
    EfiHandle(nil),
    efiOpenProtocolByHandleProtocol)

  if efiError(result): return

  freePool gopHandles

proc calcLoadAddressRange(ehdr: ptr Elf64Ehdr): tuple[first, last: culonglong] =
  let phdr = cast[ptr UncheckedArray[Elf64Phdr]](cast[uint64](ehdr) + ehdr.phoff)
  result.first = high(uint64)
  result.last = 0
  for i in 0..<int(ehdr.phnum):
    if phdr[i].`type` != ptLoad: continue
    result.first = min(result.first, phdr[i].vaddr)
    result.last = max(result.last, phdr[i].vaddr + phdr[i].memsz)

proc copyLoadSegments(ehdr: ptr Elf64Ehdr) =
  let phdr = cast[ptr UncheckedArray[Elf64Phdr]](cast[uint64](ehdr) + ehdr.phoff)

  for i in 0..<int(ehdr.phnum):
    if phdr[i].`type` != ptLoad: continue

    var segmInFile = cast[uint64](ehdr) + phdr[i].offset
    discard copyMem(cast[pointer](phdr[i].vaddr), cast[pointer](segmInFile), phdr[i].filesz)

    let remainBytes = phdr[i].memsz - phdr[i].filesz
    discard setMem(cast[pointer](phdr[i].vaddr + phdr[i].filesz), remainBytes, 0)


proc uefiMain(imageHandle: EfiHandle; systemTable: ptr EfiSystemTable): EfiStatus {.efidecl.} =
  var status: EfiStatus

  print fastwidestr("Hello, Mikan World!\n")

  var
    memmapBuf: array[4_096 * 4, uint8]
    memmap = MemoryMap(bufferSize: uint64(sizeof(memmapBuf)), buffer: addr memmapBuf[0])

  status = getMemoryMap(memmap)
  if efiError(status):
    print fastwidestr("failed to get memory map: %r\n"), status
    halt()

  var rootDir: ptr EfiFileProtocol
  status = openRootDir(imageHandle, rootDir)
  if efiError(status):
    print fastwidestr("failed to open root directory: %r\n"), status
    halt()

  # GOP でピクセル描画
  var gop: ptr EfiGraphicsOutputProtocol
  status = openGop(imageHandle, gop)
  if efiError(status):
    print fastwidestr("failed to open GOP: %r\n"), status
    halt()

  var
    frameBuffer = cast[ptr UncheckedArray[uint8]](gop.mode.frameBufferBase)

  var config = FrameBufferConfig(
    frameBuffer: frameBuffer,
    pixelsPerScanLine: gop.mode.info.pixelsPerScanLine,
    horizontalResolution: gop.mode.info.horizontalResolution,
    verticalResolution: gop.mode.info.verticalResolution)

  case gop.mode.info.pixelFormat
  of PixelRedGreenBlueReserved8BitPerColor:
    config.pixelFormat = PixelFormat.pixelRGBResv8BitPerColor
  of PixelBlueGreenRedReserved8BitPerColor:
    config.pixelFormat = PixelFormat.pixelBGRResv8BitPerColor
  else:
    print fastwidestr("Unimplemented pixel format: %s\n"), $gop.mode.info.pixelFormat
    halt()

  for x in 0..<int(config.horizontalResolution):
    for y in 0..<int(config.verticalResolution):
      config.writePixel(x, y, (0x66'u8, 0xCC'u8, 0xFF'u8))

  # カーネルを読み込む
  var kernelFile: ptr EfiFileProtocol
  status = rootDir[].open(rootDir, addr kernelFile, fastwidestr"\kernel.elf", efiFileModeRead, 0'u64)
  if efiError(status):
    print fastwidestr("failed to open file '\\kernel.elf': %r\n"), status
    halt()

  var
    fileInfoSize = culonglong(sizeof(EfiFileInfo) + sizeof(uint16) * 12)
    fileInfoBuffer: array[sizeof(EfiFileInfo) + sizeof(uint16) * 12, uint8]

  status = kernelFile[].getInfo(kernelFile, addr gEfiFileInfoGuid, addr fileInfoSize, addr fileInfoBuffer[0])
  if efiError(status):
    print fastwidestr("failed to get file information: %r\n"), status

  let fileInfo = cast[ptr EfiFileInfo](addr fileInfoBuffer[0])
  var kernelFileSize: culonglong = fileInfo.fileSize

  var kernelBuffer: pointer
  status = gBS[].allocatePool(EfiLoaderData, kernelFileSize, addr kernelBuffer)
  if efiError(status):
    print fastwidestr("failed to allocate pool: %r\n"), status
    halt()

  status = kernelFile[].read(kernelFile, addr kernelFileSize, kernelBuffer)
  if efiError(status):
    print fastwidestr("failed to read kernel file: %r\n"), status

  var
    kernelEhdr = cast[ptr Elf64Ehdr](kernelBuffer)
    (kernelFirstAddr, kernelLastAddr) = calcLoadAddressRange(kernelEhdr)
  let numPages: uint64 = (kernelLastAddr - kernelFirstAddr + 0xfff) div 0x1000

  status = gBS[].allocatePages(AllocateAddress, EfiLoaderData, numPages, addr kernelFirstAddr)
  if efiError(status):
    print fastwidestr("failed to allocate pages: %r\n"), status
    print fastwidestr("F: 0x%0lx, L: 0x%0lx, N: %d\n"), kernelFirstAddr, kernelLastAddr, numPages
    halt()

  copyLoadSegments(kernelEhdr)
  print fastwidestr("Kernel: 0x%0lx - 0x%0lx\n"), kernelFirstAddr, kernelLastAddr

  status = gBS[].freePool(kernelBuffer)
  if efiError(status):
    print fastwidestr("failed to free pool: %r\n"), status
    halt()

  var entryAddr = cast[ptr uint64](kernelFirstAddr + 24)[]
  print fastwidestr("Kernel entry: 0x%0lx\n"), entryAddr

  # ブートローダーを閉じる
  status = gBS[].exitBootServices(imageHandle, memmap.mapKey)
  if efiError(status):
    status = getMemoryMap(memmap)

    if efiError(status):
      print fastwidestr("failed to get memory map: %r\n"), status

    status = gBS[].exitBootServices(imageHandle, memmap.mapKey)

    if efiError(status):
      print fastwidestr("Could not exit boot service: %r\n"), status

  # カーネルを呼ぶ
  {.emit: ["typedef void EntryPointType(const FrameBufferConfig *); EntryPointType* entryPoint = (EntryPointType*)", entryAddr, "; entryPoint(", addr(config) ,");"].}

  print fastwidestr("All done\n")

  while true: discard
