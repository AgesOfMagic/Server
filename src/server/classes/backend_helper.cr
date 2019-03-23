# This class is being in charge of the handling of incoming packets
class Backend::Helper
  # Handles the HANDLE_HANDSHAKE_CLIENT_TYPE packets
  # the code will generate a raw_client
  def self.handle_handshake_client_type(message, client, clients_arr)
    raw_client = Protocol.bufferToHandShakeClient(message)
    constructed_client = Player.construct(client, raw_client)
    clients_arr << constructed_client

    hand_shake_struct = Protocol::HandShakeServer.new(
      status: Protocol::Status::OK,
      serverVersion: StaticArray(UInt8, 16).new(0_u8),
      characterData: StaticArray(UInt8, 492).new(0_u8))
    buff = Protocol.handShakeServerToBuffer(hand_shake_struct)

    client.send(buff.to_slice(512))
  end

  # Handles the HANDLE_MOVEMENT_PACKET_TYPE packets
  def self.handle_movement_packet_type(message, client, clients_arr)
    movement_packet = Protocol.bufferToMovement(message)
    # Broadcast the new position with UpdateMovement
    if desired_player = clients_arr.find {|o| o.tcp == client}
      desired_player.update_position(movement_packet.direction)
      updatePositionStruct = Protocol::UpdatePosition.new(
      x: desired_player.@posX,
      y: desired_player.@posY,
      id: desired_player.@id)

      buffer = Protocol.updatePositionToBuffer(updatePositionStruct)
      clients_arr.each do |socket|
        puts "
        Sending new update position buffer to #{socket.@id}
        ====================#{movement_packet.direction}=========================
        Client array count =======> #{clients_arr.size}
        ===============================================
        Position X: #{desired_player.@posX}
        Position Y: #{desired_player.@posY}
        "
        socket.tcp.send(buffer.to_slice(512))
      end
    end
  end
end
