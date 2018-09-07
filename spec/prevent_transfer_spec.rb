require_relative '../container'
require_relative '../card'
require_relative '../global_hooks'
require_relative '../card_kernel'

class PreventerCard < Card
  def initialize(id:, global_hooks: nil)
    super(id: id, global_hooks: global_hooks)

    # Execute this before transferring
    @pre[:transfer] = lambda { |args|

      # If it's being moved to 1
      if(args[:next_container].id == 1)


        # Add a pre_transfer to the global scope
        lambda_hook = lambda { |args|

          if (!args[:prev_container].nil? && args[:prev_container].id == 2) && args[:next_container].id == 3 && args[:card].type == :my_type
            return false
          end

          return true
        }

        @global_hooks.append_hook(:pre, event_name: :transfer, fn: lambda_hook, card_owner_id: @id)

      else

        # If it wasn't moved to 1, then remove that pre_transfer
        @global_hooks.remove_by_card_id(:pre, event_name: :transfer, card_owner_id: @id)
      end

    }

  end
end


describe Container do
  it "card1 prevents card2 from transferring (if card1 is in 1 and card2 moves from 2 to 3)" do

    k = CardKernel.new

    global_hooks = GlobalHooks.new

    cont1 = Container.new(id: 1, global_hooks: global_hooks)
    cont2 = Container.new(id: 2, global_hooks: global_hooks)
    cont3 = Container.new(id: 3, global_hooks: global_hooks)

    k.add_container cont1
    k.add_container cont2
    k.add_container cont3

    card1 = PreventerCard.new(id: 11, global_hooks: global_hooks)
    card2 = Card.new(id: 22, type: :my_type, global_hooks: global_hooks)

    cont1.add_card card1
    cont1.add_card card2

    expect(cont1.cards.length).to eq 2
    expect(cont2.cards.length).to eq 0
    expect(cont3.cards.length).to eq 0

    k.transfer_by_ids(prev_container_id: 1, next_container_id: 2, card_id: 22)

    expect(cont1.cards.length).to eq 1
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 0

    k.transfer_by_ids(prev_container_id: 2, next_container_id: 3, card_id: 22)

    expect(cont1.cards.length).to eq 1
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 0

    # Move card1 away from container1, so now it doesn't prevent card2 from transferring

    k.transfer_by_ids(prev_container_id: 1, next_container_id: 2, card_id: 11)

    expect(cont1.cards.length).to eq 0
    expect(cont2.cards.length).to eq 2
    expect(cont3.cards.length).to eq 0

    k.transfer_by_ids(prev_container_id: 2, next_container_id: 3, card_id: 22)

    expect(cont1.cards.length).to eq 0
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 1

    # Move again back to the prevention position

    k.transfer_by_ids(prev_container_id: 2, next_container_id: 1, card_id: 11)

    expect(cont1.cards.length).to eq 1
    expect(cont2.cards.length).to eq 0
    expect(cont3.cards.length).to eq 1

    # It can move because the prevention is unidirectional

    k.transfer_by_ids(prev_container_id: 3, next_container_id: 2, card_id: 22)

    expect(cont1.cards.length).to eq 1
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 0

    # Verify again it can't move in the prevented direction

    k.transfer_by_ids(prev_container_id: 2, next_container_id: 3, card_id: 22)

    expect(cont1.cards.length).to eq 1
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 0

  end

end
