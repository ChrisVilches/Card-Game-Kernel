require './card.rb'

class Container

  attr_reader :id, :cards

  def initialize(id:)
    @cards = Array.new
    @id = id
  end

  def add_card(card, from_container: nil)

    if card.nil?
      return { transfer: false }
    end

    @cards << card
    return card.trigger_event :transfer, { prev_container: from_container.nil?? nil : from_container.id, next_container: @id, transfer: true }
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
    @cards.delete_at(index)
    return transfer(card: card, to: to)

  end

  private
  def transfer(card:, to:)
    return to.add_card(card, from_container: self)
  end

end
