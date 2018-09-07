require_relative '../../container'
require_relative '../../card'
require_relative '../../card_kernel'

$temporary_money = 10 # Global variable for now


class MyCard < Card

  def initialize(id:, type: nil, global_hooks: nil)
    super(id: id, type: type, global_hooks: global_hooks)
    on :pre, :transfer, :pre_transfer
  end

  def pre_transfer(args)

    if !args[:prev_container].nil? && args[:prev_container].id == [:a] && args[:next_container].id == [:b] && args[:card].type == :kazooie

      # Use the player's attributes here
      $temporary_money = $temporary_money - 3
    end

    return { transfer: true }
  end

end


describe CardKernel do
  it "should force the player to spend money in order to transfer a card from one container to another" do

    k = CardKernel.new
    a = k.create_container [:a]
    b = k.create_container [:b]

    card = MyCard.new id: 1, type: :kazooie
    
    a.add_card card

    expect($temporary_money).to be 10

    k.transfer_by_ids(prev_container_id: [:a], next_container_id: [:b], card_id: 1)
    expect($temporary_money).to be 7

    k.transfer_by_ids(prev_container_id: [:b], next_container_id: [:a], card_id: 1)
    expect($temporary_money).to be 7

    k.transfer_by_ids(prev_container_id: [:a], next_container_id: [:b], card_id: 1)
    expect($temporary_money).to be 4


  end


end
