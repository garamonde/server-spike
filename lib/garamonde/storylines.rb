class Garamonde::Storylines

  def initialize
    @storylines = {}
  end

  def start(keyw = {})
    session = keyw[:session]
    
    yield @storylines[session.user.email] ||= OpenStruct.new(
      status: "started",
      id: new_id,
      updates: []
    )
  end

  def lookup(keyw = {})
    id = keyw[:id]

    yield @storylines.values.detect{|sl| sl.id == id }
  end

  def add_updates(keyw = {})
    id = keyw[:id]
    updates = keyw[:updates]
    
    lookup(id: id) do |storyline|
      storyline.updates += updates
    end
  end

  private

  def new_id
    SecureRandom.hex
  end

end
