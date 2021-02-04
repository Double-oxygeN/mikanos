import ../util/error

const
  configAddress* = 0x0cf8'u16
  configData* = 0x0cfc'u16

type
  Device* = tuple
    bus: uint8
    device: range[0'u8..31'u8]
    function: range[0'u8..7'u8]
    headerType: uint8

var
  devices*: array[32, Device]
  numDevice* = 0

proc ioOut32(address: uint16; data: uint32) {.importc: "IoOut32", nodecl.}
proc ioIn32(address: uint16): uint32 {.importc: "IoIn32", nodecl.}

proc makeAddress(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]; regAddr: uint8): uint32 =
  result = (1'u32 shl 31) or (uint32(bus) shl 16) or (uint32(device) shl 11) or (uint32(function) shl 8) or uint32(regAddr and 0xfc'u8)

proc writeAddress(address: uint32) =
  ioOut32(configAddress, address)

proc writeData(value: uint32) =
  ioOut32(configData, value)

proc readData: uint32 =
  result = ioIn32(configData)

proc readVendorId*(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]): uint16 =
  writeAddress(makeAddress(bus, device, function, 0x00'u8))
  result = uint16(readData())

proc readDeviceId(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]): uint16 =
  writeAddress(makeAddress(bus, device, function, 0x00'u8))
  result = uint16(readData() shr 16)

proc readHeaderType(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]): uint8 =
  writeAddress(makeAddress(bus, device, function, 0x0c'u8))
  result = uint8(readData() shr 16)

proc readClassCode*(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]): uint32 =
  writeAddress(makeAddress(bus, device, function, 0x08'u8))
  result = readData()

proc readBusNumbers(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]): uint32 =
  writeAddress(makeAddress(bus, device, function, 0x18'u8))
  result = readData()

proc isSingleFunctionDevice(headerType: uint8): bool =
  result = (headerType and 0x80'u8) == 0'u8

proc addDevice(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]; headerType: uint8): Error =
  if numDevice == devices.len:
    return Error.full

  devices[numDevice] = (bus, device, function, headerType)
  inc numDevice
  return Error.success

proc scanBus(bus: uint8): Error

proc scanFunction(bus: uint8; device: range[0'u8..31'u8]; function: range[0'u8..7'u8]): Error =
  result = Error.success
  let
    headerType = readHeaderType(bus, device, function)
    err = addDevice(bus, device, function, headerType)

  if err:
    return err

  let
    classCode = readClassCode(bus, device, function)
    base = uint8(classCode shr 24)
    sub = uint8(classCode shr 16)

  if base == 0x06'u8 and sub == 0x04'u8:
    let
      busNumbers = readBusNumbers(bus, device, function)
      secondaryBus = uint8(busNumbers shr 8)
    return scanBus(secondaryBus)

proc scanDevice(bus: uint8; device: range[0'u8..31'u8]): Error =
  result = Error.success
  let err = scanFunction(bus, device, 0)
  if err:
    return err

  if readHeaderType(bus, device, 0).isSingleFunctionDevice:
    return Error.success

  for function in 1'u8..7'u8:
    if readVendorId(bus, device, function) == 0xffff'u16:
      continue

    let err = scanFunction(bus, device, function)
    if err:
      return err

proc scanBus(bus: uint8): Error =
  result = Error.success
  for device in 0'u8..31'u8:
    if readVendorId(bus, device, 0) == 0xffff'u16:
      continue

    let err = scanDevice(bus, device)
    if err:
      return err

proc scanAllBus*: Error =
  numDevice = 0

  let headerType = readHeaderType(0, 0, 0)
  if headerType.isSingleFunctionDevice:
    return scanBus(0)

  for function in 1'u8..7'u8:
    if readVendorId(0, 0, function) == 0xffff'u16:
      continue

    let err = scanBus(function)
    if err:
      return err
