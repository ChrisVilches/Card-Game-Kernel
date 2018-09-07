require './card.rb'

class NullCard < StandardError
  def initialize(msg="Attempted to add a null card to a container")
    super
  end
end

class Container

  attr_reader :id, :cards, :containers

  def initialize(id:, global_hooks: nil)
    @cards = Array.new
    @id = id
    @global_hooks = global_hooks
    @global_hooks = GlobalHooks.new if @global_hooks.nil?

    @containers = Hash.new;
  end

  def trigger_event(event:, arguments: {}, recursive: false)
    @cards.each do |card|
      card.trigger_event(event: event, arguments: arguments)
    end

    if recursive == true
      @containers.each do |key, container|
        container.trigger_event(event: event, arguments: arguments)
      end
    end

    return nil
  end

  def add_card(card, from_container: nil)

    if card.nil?
      raise NullCard.new
    end

    add_result = card.trigger_event(event: :transfer, arguments: {
      prev_container: from_container.nil?? nil : from_container,
      next_container: self
      }
    )

    if add_result != false && add_result[:transfer] == true
      @cards << card
    end

    return add_result

  end


end
