require_relative '../container'
require_relative '../card'

describe Container do
  it "should transfer_by_id correctly" do
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    card = Card.new id: 1
    c1.add_card card
    expect(c1.cards.length).to eq 1
    expect(c2.cards.length).to eq 0
    c1.transfer_by_id(card_id: 1, to: c2)
    expect(c1.cards.length).to eq 0
    expect(c2.cards.length).to eq 1
  end

  it "should transfer_by_id correctly if card doesn't exist" do
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    card = Card.new id: 1
    c1.add_card card
    expect(c1.cards.length).to eq 1
    expect(c2.cards.length).to eq 0
    c1.transfer_by_id(card_id: 2, to: c2)
    expect(c1.cards.length).to eq 1
    expect(c2.cards.length).to eq 0
  end

end
