require_relative '../container'
require_relative '../card'


class PreventerCard < Card
  def initialize(id:, global_state: nil)
    super(id: id, global_state: global_state)

    # Execute this before transferring
    @pre[:transfer] = lambda { |args|

      # If it's being moved to 1
      if(args[:next_container].id == 1)

        @global_state[:pre] = {} if !@global_state.has_key?(:pre)
        @global_state[:pre][:transfer] = [] if !@global_state[:pre].has_key?(:transfer)

        # Add a pre_transfer to the global scope
        @global_state[:pre][:transfer] << {

          card_id: @id,

          fn: lambda { |args|

            if args[:next_container].id == 3 && args[:card].type == :my_type
              return false
            end

            return true
          }
        }
      else

        # If it wasn't moved to 1, then remove that pre_transfer
        remove_index = nil
        @global_state[:pre][:transfer].each_with_index do |x, i|

          if(x[:card_id] == @id)
            remove_index = i
            break
          end

        end
        @global_state[:pre][:transfer].delete_at remove_index
      end

    }

  end
end


describe Container do
  it "card1 prevents card2 from transferring (if card1 is in 1 and card2 moves from 2 to 3)" do

    global_state = Hash.new
    global_state[:pre] = {}

    cont1 = Container.new(id: 1, global_state: global_state)
    cont2 = Container.new(id: 2, global_state: global_state)
    cont3 = Container.new(id: 3, global_state: global_state)

    card1 = PreventerCard.new(id: 11, global_state: global_state)
    card2 = Card.new(id: 22, type: :my_type, global_state: global_state)

    cont1.add_card card1
    cont1.add_card card2

    expect(cont1.cards.length).to eq 2
    expect(cont2.cards.length).to eq 0
    expect(cont3.cards.length).to eq 0

    cont1.transfer_by_id(card_id: 22, to: cont2)

    expect(cont1.cards.length).to eq 1
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 0

    cont2.transfer_by_id(card_id: 22, to: cont3)

    expect(cont1.cards.length).to eq 1
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 0

    # Move card1 away from container1, so now it doesn't prevent card2 from transferring

    cont1.transfer_by_id(card_id: 11, to: cont2)

    expect(cont1.cards.length).to eq 0
    expect(cont2.cards.length).to eq 2
    expect(cont3.cards.length).to eq 0

    cont2.transfer_by_id(card_id: 22, to: cont3)

    expect(cont1.cards.length).to eq 0
    expect(cont2.cards.length).to eq 1
    expect(cont3.cards.length).to eq 1

  end

end
