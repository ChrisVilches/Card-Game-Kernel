require './card.rb'

class Container

  attr_reader :id, :cards

  def initialize(id:, global_state: nil)
    @cards = Array.new
    @id = id
    @global_state = global_state
    @global_state = {} if @global_state.nil?
  end

  def add_card(card, from_container: nil)

    if card.nil?
      return { transfer: false }
    end

    1.times do
      pre = @global_state[:pre]
      break if pre.nil?

      pre_transfer = pre[:transfer]
      break if pre_transfer.nil?

      #result_pre_transfer = pre_transfer.call({ card: card, prev_container: from_container, next_container: self })

      result_pre_transfer = merge_all_global(pre_transfer, { card: card, prev_container: from_container, next_container: self }) 

      return { transfer: false } if result_pre_transfer == false
    end


    @cards << card

    return card.trigger_event(:transfer, { prev_container: from_container.nil?? nil : from_container, next_container: self })
  end


  def merge_all_global(array, arguments)

    results = {}

    array.each do |hook|

      res = hook[:fn].call(arguments)
      if res == false
        return false
      end

      if res.is_a?(Hash)
        results = results.merge(res)
      end

    end

    return results
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

    1.times do
      pre = @global_state[:pre]
      break if pre.nil?

      pre_transfer = pre[:transfer]
      break if pre_transfer.nil?

      #result_pre_transfer = pre_transfer.call({ card: card, prev_container: self, next_container: to })

      result_pre_transfer = merge_all_global(pre_transfer, { card: card, prev_container: self, next_container: to })

      return transfer(card: nil, to: to) if result_pre_transfer == false
    end

    @cards.delete_at(index)
    return transfer(card: card, to: to)

  end

  private
  def transfer(card:, to:)
    return to.add_card(card, from_container: self)
  end

end
