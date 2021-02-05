type
  Error* {.pure.} = enum
    success
    full
    empty
    noEnoughMemory
    indexOutOfRange
    hostControllerNotHalted
    invalidSlotId
    portNotConnected
    invalidEndpointNumber
    transferRingNotSet
    alreadyAllocated
    notImplemented
    invalidDescriptor
    bufferTooSmall
    unknownDevice
    noCorrespondingSetupStage
    transferFailed
    invalidPhase
    unknownXhciSpeedId
    noWaiter
    lastOfCode

converter toBool*(x: Error): bool = x != Error.success
