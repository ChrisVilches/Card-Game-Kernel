require './global_hooks.rb'

class ImpossibleTransfer < StandardError
  def initialize(msg="Transference is impossible to perform")
    super
  end
end

class ContainerNotFound < StandardError
  def initialize(msg="Container not found")
    super
  end
end


class CardKernel

  attr_reader :containers

  def initialize
    @global_hooks = GlobalHooks.new
    @containers = Hash.new
  end


  def transfer_by_ids(prev_container_id:, next_container_id:, card_id:)

    prev_container = find_container prev_container_id
    next_container = find_container next_container_id

    index = nil
    (0..prev_container.cards.length-1).each do |i|
      if prev_container.cards[i].id == card_id
        index = i
        break
      end
    end
    return { transfer: false } if index == nil
    card = prev_container.cards[index]

    transfer_result = card.trigger_event(event: :transfer, arguments: { prev_container: prev_container.nil?? nil : prev_container, next_container: next_container, card: card })

    if transfer_result != false && transfer_result[:transfer] == true
      next_container.cards << card
      prev_container.cards.delete_at(index)
    end

    return { transfer: false } if transfer_result == false
    return transfer_result

  end


  def create_container(path)

    if path.length == 1
      new_container = Container.new(id: path) # Remove ID
      @containers[path.first] = new_container
      return new_container
    end

    curr_container = @containers[path[0]]
    raise ContainerNotFound if curr_container.nil?

    (1..path.length-2).each do |i|
      curr_container = curr_container.containers[path[i]]
      raise ContainerNotFound if curr_container.nil?
    end

    new_container = Container.new(id: path) # Remove ID
    curr_container.containers[path.last] = new_container

    return new_container

  end

  def find_container(path)

    curr_container = @containers[path[0]]
    raise ContainerNotFound if curr_container.nil?

    return curr_container if path.length == 1

    (1..path.length-1).each do |i|
      curr_container = curr_container.containers[path[i]]
      raise ContainerNotFound if curr_container.nil?
    end

    return curr_container
  end

end
