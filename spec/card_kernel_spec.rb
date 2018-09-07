require_relative '../container'
require_relative '../card'
require_relative '../card_kernel'

describe CardKernel do
  it "should transfer_by_ids correctly" do

    k = CardKernel.new

    c1 = Container.new id: 11
    c2 = Container.new id: 22

    k.add_container c1
    k.add_container c2

    card = Card.new id: 1
    c1.add_card card
    expect(c1.cards.length).to eq 1
    expect(c2.cards.length).to eq 0
    k.transfer_by_ids(prev_container_id: 11, next_container_id: 22, card_id: 1)
    expect(c1.cards.length).to eq 0
    expect(c2.cards.length).to eq 1
  end

  it "should transfer_by_id correctly if card doesn't exist" do

    k = CardKernel.new

    c1 = Container.new id: 11
    c2 = Container.new id: 22

    k.add_container c1
    k.add_container c2

    card = Card.new id: 1
    c1.add_card card
    expect(c1.cards.length).to eq 1
    expect(c2.cards.length).to eq 0
    k.transfer_by_ids(prev_container_id: 11, next_container_id: 22, card_id: 2)
    expect(c1.cards.length).to eq 1
    expect(c2.cards.length).to eq 0
  end

end
