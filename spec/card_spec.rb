require_relative '../card'

describe Card do
  it "should compute to_s correctly" do
    c = Card.new(id: 3)
    expect(c.to_s).to eq 3
  end

  it "should transfer and return correctly" do
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    card = Card.new id: 1
    c1.add_card card
    event_result = c1.transfer_by_id(card_id: 1, to: c2)
    expect(event_result[:prev_container].id).to eq 11
    expect(event_result[:next_container].id).to eq 22
    expect(event_result[:transfer]).to be true

    event_result = c2.transfer_by_id(card_id: 1, to: c1)
    expect(event_result[:prev_container].id).to eq 22
    expect(event_result[:next_container].id).to eq 11
    expect(event_result[:transfer]).to be true
  end

  it "should transfer and return correctly if the container is the same" do
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    card = Card.new id: 1
    c1.add_card card
    event_result = c1.transfer_by_id(card_id: 1, to: c1)
    expect(event_result[:prev_container].id).to eq 11
    expect(event_result[:next_container].id).to eq 11
    expect(event_result[:transfer]).to be true
  end

  it "should transfer and return correctly if the card is not found" do
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    card = Card.new id: 1
    c1.add_card card
    event_result = c1.transfer_by_id(card_id: 2, to: c1)
    expect(event_result[:transfer]).to be false
  end


end
