class Entity
  property posX : Int32
  property posY : Int32
  property id : UInt32

  def initialize(@id = id)
    @posX = 0
    @posY = 0
    @id = 0
  end
end
