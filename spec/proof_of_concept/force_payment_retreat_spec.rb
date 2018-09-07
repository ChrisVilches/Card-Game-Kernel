require_relative '../../container'
require_relative '../../card'

$temporary_money = 10 # Global variable for now


class MyCard < Card

  def initialize(id:, type: nil, global_hooks: nil)
    super(id: id, type: type, global_hooks: global_hooks)
    on :pre, :transfer, :pre_transfer
  end

  def pre_transfer(args)

    if !args[:prev_container].nil? && args[:prev_container].id == 1 && args[:next_container].id == 2 && args[:card].type == :kazooie

      # Use the player's attributes here
      $temporary_money = $temporary_money - 3
    end

    return { transfer: true }
  end

end


describe CardKernel do
  it "should force the player to spend money in order to transfer a card from one container to another" do

    k = CardKernel.new

    card = MyCard.new id: 1, type: :kazooie

    cont1 = Container.new id: 1
    cont2 = Container.new id: 2

    k.add_container cont1
    k.add_container cont2

    cont1.add_card card

    expect($temporary_money).to be 10

    k.transfer_by_ids!(prev_container_id: 1, next_container_id: 2, card_id: 1)
    expect($temporary_money).to be 7

    k.transfer_by_ids!(prev_container_id: 2, next_container_id: 1, card_id: 1)
    expect($temporary_money).to be 7

    k.transfer_by_ids!(prev_container_id: 1, next_container_id: 2, card_id: 1)
    expect($temporary_money).to be 4


  end


end
