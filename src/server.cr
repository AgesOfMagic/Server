require "socket"
require "./server/c_bindings/bindings.cr"
require "./server/classes/*"

clients_arr = Array(Player).new 0

server = TCPServer.new(3000)
loop do
  if socket = server.accept?
    # handle the client in a fiber
    puts "Client connected"
    spawn handle_connection(socket, clients_arr)
  else
    # another fiber closed the server
    break
  end
end

def handle_connection(socket, clients_arr)
  loop do
    buffer = Bytes.new 512
    socket.read buffer
    # buffer = String.new buffer
    decide_operation(buffer, socket, clients_arr)
  end
rescue ex : Errno
  if ex.errno == Errno::ECONNRESET
    if socket_to_disconnect = clients_arr.find {|o| o.tcp == socket}
      clients_arr.delete(socket_to_disconnect)
      puts "Disconnected succesfully"
      puts "LENGTH AFTER DISCONNECT => #{clients_arr.size}"
    end
  end
end

def decide_operation(message, client, clients_arr)
  id = String.new(message)[0] # The first byte is in charge of the stage
  curr_type = Protocol.identify(id.ord.to_u8, 0)

  case curr_type
  when Protocol::PacketTypes::HAND_SHAKE_CLIENT_TYPE
    puts "Establishing an handshake client type"
    Backend::Helper.handle_handshake_client_type(message, client, clients_arr)
  when Protocol::PacketTypes::MOVEMENT_PACKET_TYPE
    Backend::Helper.handle_movement_packet_type(message, client, clients_arr)
  end
end
