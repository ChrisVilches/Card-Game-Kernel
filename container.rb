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

    result_pre_transfer = @global_hooks.merge_all(:pre, event_name: :transfer, arguments: { card: card, prev_container: from_container, next_container: self })
    return transfer(card: nil, to: to) if result_pre_transfer == false


    @cards << card

    return card.trigger_event(:transfer, { prev_container: from_container.nil?? nil : from_container, next_container: self })
  end




  def transfer_by_id(to:, card_id:)
    index = nil
    (0..@cards.length-1).each do |i|
      if @cards[i].id == card_id
        index = i
        break
      end
    end
    return transfer(card: nil, to: to) if index == nil
    card = @cards[index]


    result_pre_transfer = @global_hooks.merge_all(:pre, event_name: :transfer, arguments: { card: card, prev_container: self, next_container: to })
    return transfer(card: nil, to: to) if result_pre_transfer == false

    @cards.delete_at(index)
    return transfer(card: card, to: to)

  end

  private
  def transfer(card:, to:)
    return to.add_card(card, from_container: self)
  end

end
