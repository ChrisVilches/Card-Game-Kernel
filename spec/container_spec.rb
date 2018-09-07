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
  end

  it "should transfer_by_id correctly if card doesn't exist" do
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    card = Card.new id: 1
    c1.add_card card
    expect(c1.cards.length).to eq 1
    expect(c2.cards.length).to eq 0
  end

  it "should raise an exception when adding a null card" do
    cont = Container.new id: 1
    expect{ cont.add_card nil }.to raise_error NullCard
  end

end
