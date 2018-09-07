require_relative '../../container'
require_relative '../../card'
require_relative '../../global_hooks'
require_relative '../../card_kernel'

class PreventerCard < Card
  def initialize(id:, global_hooks: nil)
    super(id: id, global_hooks: global_hooks)

    # Execute this before transferring
    on :pre, :transfer, :on_transfer

  end


  def on_transfer(args)
    # If it's being moved to 1
    if(args[:next_container].id == [:a])


      # Add a pre_transfer to the global scope
      lambda_hook = lambda { |args|

        if (!args[:prev_container].nil? && args[:prev_container].id == [:b]) && args[:next_container].id == [:b, :c] && args[:card].type == :my_type
          return false
        end

        return true
      }

      @global_hooks.append_hook(:pre, event_name: :transfer, fn: lambda_hook, card_owner_id: @id)

    else
      # If it wasn't moved to 1, then remove that pre_transfer
      @global_hooks.remove_by_card_id(:pre, event_name: :transfer, card_owner_id: @id)
    end

  end

end


describe CardKernel do
  it "card1 prevents card2 from transferring (if card1 is in 1 and card2 moves from 2 to 3)" do

    k = CardKernel.new
    a = k.create_container [:a]
    b = k.create_container [:b]
    c = k.create_container [:b, :c]

    global_hooks = GlobalHooks.new

    card1 = PreventerCard.new(id: 11, global_hooks: global_hooks)
    card2 = Card.new(id: 22, type: :my_type, global_hooks: global_hooks)

    a.add_card card1
    a.add_card card2

    expect(a.cards.length).to eq 2
    expect(b.cards.length).to eq 0
    expect(c.cards.length).to eq 0

    k.transfer_by_ids(prev_container_id: [:a], next_container_id: [:b], card_id: 22)

    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 1
    expect(c.cards.length).to eq 0

    k.transfer_by_ids(prev_container_id: [:b], next_container_id: [:b, :c], card_id: 22)

    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 1
    expect(c.cards.length).to eq 0

    # Move card1 away from container1, so now it doesn't prevent card2 from transferring

    k.transfer_by_ids!(prev_container_id: [:a], next_container_id: [:b], card_id: 11)

    expect(a.cards.length).to eq 0
    expect(b.cards.length).to eq 2
    expect(c.cards.length).to eq 0

    k.transfer_by_ids!(prev_container_id: [:b], next_container_id: [:b, :c], card_id: 22)

    expect(a.cards.length).to eq 0
    expect(b.cards.length).to eq 1
    expect(c.cards.length).to eq 1

    # Move again back to the prevention position

    k.transfer_by_ids!(prev_container_id: [:b], next_container_id: [:a], card_id: 11)

    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 0
    expect(c.cards.length).to eq 1

    # It can move because the prevention is unidirectional

    k.transfer_by_ids!(prev_container_id: [:b, :c], next_container_id: [:b], card_id: 22)

    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 1
    expect(c.cards.length).to eq 0

    # Verify again it can't move in the prevented direction

    k.transfer_by_ids(prev_container_id: [:b], next_container_id: [:b, :c], card_id: 22)

    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 1
    expect(c.cards.length).to eq 0

  end

end
