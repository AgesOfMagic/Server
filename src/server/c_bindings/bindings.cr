# gguur.o
@[Link(ldflags: "#{__DIR__}/lib/protocol.o")]

lib Protocol
  enum Status
    UNRECOGNIZED
    OK
    UNMATCHED_VERSION
    UNKNOWON_CHARACTER
  end

  enum PacketTypes
    UNKNOWN
    HAND_SHAKE_CLIENT_TYPE
    HAND_SHAKE_SERVER_TYPE
    MOVEMENT_PACKET_TYPE
  end

  enum Direction
    NORTH
    SOUTH
    WEST
    EAST
  end

  struct HandShakeClient
    displayName : StaticArray(UInt8, 128)
    clientVersion : StaticArray(UInt8, 16)
    characterSecret : StaticArray(UInt8, 32)
  end

  struct HandShakeServer
    status : Status
    serverVersion : StaticArray(UInt8, 16)
    characterData : StaticArray(UInt8, 492)
  end

  struct MovementPacket
    direction : Direction
    characterSecret : StaticArray(UInt8, 32)
  end

  struct UpdatePosition
    x : Int32
    y : Int32
    id : UInt8
  end

  fun handShakeClientToBuffer(clientPacket : HandShakeClient) : Pointer(UInt8)
  fun bufferToHandShakeClient(buff : Pointer(UInt8)) : HandShakeClient
  fun identify(id : UInt8, is_from_sever : Int32) : PacketTypes

  fun handShakeServerToBuffer(serverPacket : HandShakeServer) : Pointer(UInt8)
  fun bufferToHandShakeServer(buff : Pointer(UInt8)) : HandShakeServer

  fun movementToBuffer(movementPacket : MovementPacket) : Pointer(UInt8)
  fun bufferToMovement(buff : Pointer(UInt8)) : MovementPacket

  fun updatePositionToBuffer(updatePosition : UpdatePosition) : Pointer(UInt8)
  fun bufferToUpdatePosition(buff : Pointer(UInt8)) : UpdatePosition
end
