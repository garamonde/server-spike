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
    session = keyw[:session]

    yield @storylines[session.user.email]
  end

  private

  def new_id
    SecureRandom.hex
  end

end
