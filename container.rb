require './card.rb'

class Container

  attr_reader :id, :cards

  def initialize(id:, global_hooks: nil)
    @cards = Array.new
    @id = id
    @global_hooks = global_hooks
    @global_hooks = GlobalHooks.new if @global_hooks.nil?
  end

  def add_card(card, from_container: nil)

    if card.nil?
      return { transfer: false }
    end

    add_result = card.trigger_event(:transfer, { prev_container: from_container.nil?? nil : from_container, next_container: self })

    if add_result != false && add_result[:transfer] == true
      @cards << card
    end

    return add_result

  end

  private
  def transfer(card:, to:)
    return to.add_card(card, from_container: self)
  end

end
