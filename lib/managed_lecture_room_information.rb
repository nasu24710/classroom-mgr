class ManagedLectureRoomInformation
  def initialize(room_name)
    unless room_name.is_a?(String)
      raise ArgumentError,'room_name must be a String.'
    end 
    
    @room_name = room_name
  end
