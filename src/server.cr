require "socket"
require "./server/c_bindings/bindings.cr"
require "./server/classes/*"

class Server
  property port
  property name
  property clients_arr
  getter! backend_helper : Backend
  def initialize(@port : Int32, @name : String)
    @clients_arr = [] of Player
    @backend_helper = Backend.new(self)

    Logger.debug("Initializing a Server instance")
  end

  def run
    Logger.debug("Starting server at port #{@port}")
    server = TCPServer.new(@port)
    Logger.debug("A server is now running on port #{@port}")
    loop do
      if socket = server.accept?
        # handle the client in a fiber
        Logger.debug("A new client has been connected")
        spawn handle_connection(socket)
      else
        # another fiber closed the server
        break
      end
    end
  end

  def handle_connection(socket)
    loop do
      buffer = Bytes.new 512
      socket.read buffer
      Logger.debug("Reading a new buffer from a socket")
      # buffer = String.new buffer
      decide_operation(buffer, socket)
    end
  rescue ex : Errno
    Logger.error(ex)
    if socket_to_disconnect = @clients_arr.find {|o| o.tcp == socket}
      @clients_arr.delete(socket_to_disconnect)
      Logger.debug("A socket has been disconnected succesfully")
    end
  end

  def decide_operation(message, client)
    id = String.new(message)[0] # The first byte is in charge of the stage
    curr_type = Protocol.identify(id.ord.to_u8, 0)

    case curr_type
    when Protocol::PacketTypes::HAND_SHAKE_CLIENT_TYPE
      Logger.debug("Establishing an handshake client type")
      backend_helper.handle_handshake_client_type(message, client)
    when Protocol::PacketTypes::MOVEMENT_PACKET_TYPE
      backend_helper.handle_movement_packet_type(message, client)
    end
  end
end

new_server = Server.new 3000, "Amitx64_Crystal"
new_server.run
