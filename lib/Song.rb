class Song

  attr_reader :name, :artist, :duration
  attr_writer :name, :artist, :duration

  def initialize(name, artist, duration)
    @name     = name
    @artist   = artist
    @duration = duration
  end

end