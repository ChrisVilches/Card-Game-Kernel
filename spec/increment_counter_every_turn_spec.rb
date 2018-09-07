require_relative '../container'
require_relative '../card'
require_relative '../global_hooks'
require_relative '../card_kernel'

class CounterIncrementorCard < Card
  def initialize(id:, global_hooks: nil)
    super(id: id, global_hooks: global_hooks)

    @pre[:transfer] = lambda { |args_|

      # If it's being moved to 1
      if(args_[:next_container].id == 1)

        # Add a pre_transfer to the global scope
        lambda_hook = lambda { |args|

          if (args[:turn_number] % 2 == 0) || (args[:card].type != :countable_card)
            return {}
          end

          attrs = args[:card].attributes
          args[:card].set_attributes({ counter: 0 }) if !attrs.has_key?(:counter)
          curr = args[:card].attributes[:counter]

          args[:card].set_attributes({ counter: curr + 1 })

          return {}
        }

        @global_hooks.append_hook(:pre, event_name: :new_turn, fn: lambda_hook, card_owner_id: @id)

      else

        # If it wasn't moved to 1, then remove that pre_transfer
        @global_hooks.remove_by_card_id(:pre, event_name: :transfer, card_owner_id: @id)
      end

    }

  end
end


describe CardKernel do
  it "should not increment anything until the card is present" do

    k = CardKernel.new

    c1 = Container.new id: 1
    c2 = Container.new id: 2

    k.add_container c1
    k.add_container c2

    global_hooks = GlobalHooks.new

    card1 = CounterIncrementorCard.new id: 1, global_hooks: global_hooks
    card2 = Card.new id: 2, type: :countable_card, global_hooks: global_hooks
    c2.add_card card1
    c2.add_card card2

    card1.trigger_event(:new_turn, { turn_number: 0 })
    card2.trigger_event(:new_turn, { turn_number: 0 })

    expect(card2.attributes[:counter]).to be nil

    card1.trigger_event(:new_turn, { turn_number: 1 })
    card2.trigger_event(:new_turn, { turn_number: 1 })

    expect(card2.attributes[:counter]).to be nil

    card1.trigger_event(:new_turn, { turn_number: 2 })
    card2.trigger_event(:new_turn, { turn_number: 2 })

    expect(card2.attributes[:counter]).to be nil

    card1.trigger_event(:new_turn, { turn_number: 3 })
    card2.trigger_event(:new_turn, { turn_number: 3 })

    expect(card2.attributes[:counter]).to be nil

    k.transfer_by_ids(prev_container_id: 2, next_container_id: 1, card_id: 1)

    card1.trigger_event(:new_turn, { turn_number: 4 })
    card2.trigger_event(:new_turn, { turn_number: 4 })

    expect(card2.attributes[:counter]).to be nil

    card1.trigger_event(:new_turn, { turn_number: 5 })
    card2.trigger_event(:new_turn, { turn_number: 5 })

    expect(card2.attributes[:counter]).to eq 1

    card1.trigger_event(:new_turn, { turn_number: 6 })
    card2.trigger_event(:new_turn, { turn_number: 6 })

    expect(card2.attributes[:counter]).to eq 1

    card1.trigger_event(:new_turn, { turn_number: 7 })
    card2.trigger_event(:new_turn, { turn_number: 7 })

    expect(card2.attributes[:counter]).to eq 2


  end


end
