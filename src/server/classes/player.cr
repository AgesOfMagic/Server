class Player < Entity
  getter tcp

  def initialize(tcp : TCPSocket)
    @posX = 0
    @posY = 0
    @id = 0
    @tcp = tcp
  end

  def self.construct(socket : TCPSocket, raw : Protocol::HandShakeClient)
    instance = self.new(socket)
    instance.id = Random.new.rand(1e7).to_u32
    instance
  end

  def update_position(direction : Protocol::Direction)
    case direction
    when Protocol::Direction::EAST
      @posX += 1
    when Protocol::Direction::WEST
      @posX += -1
    when Protocol::Direction::NORTH
      @posY += -1
    when Protocol::Direction::SOUTH
      @posY += 1
    end
  end
end
