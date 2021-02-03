{.pragma: efidecl, cdecl, exportc, codegenDecl: "$# EFIAPI $#$#".}

import lib/[uefi, uefilib, uefibootservicestablelib, loadedimageprotocol, simplefilesystemprotocol, fileinfo]

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

  discard gBS[].openProtocol(
    imageHandle,
    addr gEfiLoadedImageProtocolGuid,
    cast[ptr pointer](addr loadedImage),
    imageHandle,
    EfiHandle(nil),
    efiOpenProtocolByHandleProtocol)

  discard gBS[].openProtocol(
    loadedImage.deviceHandle,
    addr gEfiSimpleFileSystemProtocolGuid,
    cast[ptr pointer](addr fs),
    imageHandle,
    EfiHandle(nil),
    efiOpenProtocolByHandleProtocol)

  fs[].openVolume(fs, addr root)


proc uefiMain(imageHandle: EfiHandle; systemTable: ptr EfiSystemTable): EfiStatus {.efidecl.} =
  print fastwidestr("Hello, Mikan World!\n")

  var
    memmapBuf: array[4_096 * 4, uint8]
    memmap = MemoryMap(bufferSize: uint64(sizeof(memmapBuf)), buffer: addr memmapBuf[0])

  discard getMemoryMap(memmap)

  var rootDir: ptr EfiFileProtocol
  discard openRootDir(imageHandle, rootDir)

  # カーネルを読み込む
  var kernelFile: ptr EfiFileProtocol
  discard rootDir[].open(rootDir, addr kernelFile, fastwidestr"\kernel.elf", efiFileModeRead, 0'u64)

  var
    fileInfoSize = culonglong(sizeof(EfiFileInfo) + sizeof(uint16) * 12)
    fileInfoBuffer: array[sizeof(EfiFileInfo) + sizeof(uint16) * 12, uint8]

  discard kernelFile[].getInfo(kernelFile, addr gEfiFileInfoGuid, addr fileInfoSize, addr fileInfoBuffer[0])

  let fileInfo = cast[ptr EfiFileInfo](addr fileInfoBuffer[0])
  var
    kernelFileSize: culonglong = fileInfo.fileSize

    kernelBaseAddr: EfiPhysicalAddress = 0x10_0000'u64

  discard gBS[].allocatePages(AllocateAddress, EfiLoaderData, (kernelFileSize + 0xfff) div 0x1000, addr kernelBaseAddr)
  discard kernelFile[].read(kernelFile, addr kernelFileSize, cast[pointer](kernelBaseAddr))

  print fastwidestr("Kernel: 0x%0lu (%lu bytes)\n"), kernelBaseAddr, kernelFileSize

  # ブートローダーを閉じる
  let status = gBS[].exitBootServices(imageHandle, memmap.mapKey)

  # カーネルを呼ぶ
  var entryAddr = cast[ptr uint64](kernelBaseAddr + 24)[]

  {.emit: ["typedef void EntryPointType(void); EntryPointType* entryPoint = (EntryPointType*)", entryAddr, "; entryPoint();"].}

  print fastwidestr("All done\n")

  while true: discard
