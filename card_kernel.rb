require './global_hooks.rb'

class CardKernel

  def initialize
    @global_hooks = GlobalHooks.new
    @containers = Array.new
  end

  def transfer_by_ids(prev_container_id:, next_container_id:, card_id:)

    prev_container = @containers.select { |container| container.id == prev_container_id }
    next_container = @containers.select { |container| container.id == next_container_id }

    prev_container = prev_container.first
    next_container = next_container.first

    return { transfer: false } if prev_container.nil? || next_container.nil?

    index = nil
    (0..prev_container.cards.length-1).each do |i|
      if prev_container.cards[i].id == card_id
        index = i
        break
      end
    end
    return { transfer: false } if index == nil
    card = prev_container.cards[index]

    transfer_result = card.trigger_event(:transfer, { prev_container: prev_container.nil?? nil : prev_container, next_container: next_container, card: card })

    if transfer_result != false && transfer_result[:transfer] == true
      next_container.cards << card
      prev_container.cards.delete_at(index)
    end


    return transfer_result

  end

  def add_container(container)
    @containers << container
  end

end
