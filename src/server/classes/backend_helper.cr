# This class is being in charge of the handling of incoming packets
class Backend
  def initialize(server : Server)
    @server = server
  end

  # Handles the HANDLE_HANDSHAKE_CLIENT_TYPE packets
  # the code will generate a raw_client
  def handle_handshake_client_type(message, client)
    # Extract the raw client from the buffer
    raw_client = Protocol.bufferToHandShakeClient(message)
    # Construct a new player from the raw_client : Player
    constructed_client = Player.construct(client, raw_client)
    # Push the new client to the clients array
    @server.clients_arr << constructed_client


    # Construct a new HandShake server
    hand_shake_struct = Protocol::HandShakeServer.new(
      status: Protocol::Status::OK,
      serverVersion: StaticArray(UInt8, 16).new(0_u8),
      serverName: StaticArray(UInt8, 128).new {|i| @server.name.byte_at?(i) || 0_u8})
    buff = Protocol.handShakeServerToBuffer(hand_shake_struct)

    # Send the new buffer
    client.send(buff.to_slice(512))

    # Send the already connected player's position
    @server.clients_arr.each do |player|

      updatePositionStruct = Protocol::UpdatePosition.new(
      x: player.@posX,
      y: player.@posY,
      id: player.@id)

      # Convert the UpdatePosition packet to sendable buffer
      updatePosBuff = Protocol.updatePositionToBuffer(updatePositionStruct)
      client.send(updatePosBuff.to_slice(512))
    end
  end

  # Handles the HANDLE_MOVEMENT_PACKET_TYPE packets
  def handle_movement_packet_type(message, client)
    movement_packet = Protocol.bufferToMovement(message)
    # Broadcast the new position with UpdateMovement
    if desired_player = @server.clients_arr.find {|o| o.tcp == client}
      desired_player.update_position(movement_packet.direction)
      updatePositionStruct = Protocol::UpdatePosition.new(
      x: desired_player.@posX,
      y: desired_player.@posY,
      id: desired_player.@id)

      buffer = Protocol.updatePositionToBuffer(updatePositionStruct)
      @server.clients_arr.each do |socket|
        # puts "
        # Sending new update position buffer to #{socket.@id}
        # ====================#{movement_packet.direction}=========================
        # Client array count =======> #{clients_arr.size}
        # ===============================================
        # Position X: #{desired_player.@posX}
        # Position Y: #{desired_player.@posY}
        # "
        socket.tcp.send(buffer.to_slice(512))
      end
    end
  end
end
