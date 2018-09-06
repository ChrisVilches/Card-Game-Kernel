class Card

  attr_reader :id

  def initialize(id:)
    @id = id
    @events = Hash.new

    on(:transfer, lambda{ |args| return args })
  end

  def on(event_name, call_back)
    @events[event_name] = call_back
  end

  def trigger_event(event_name, arguments = {})
    @events[event_name].call(arguments)
  end

  def to_s
    @id
  end


end
