require_relative '../card'
require_relative '../card_kernel'
require_relative '../container'

describe Card do
  it "should compute to_s correctly" do
    c = Card.new(id: 3)
    expect(c.to_s).to eq 3
  end

  it "should transfer and return correctly" do
    k = CardKernel.new
    c1 = Container.new id: 11
    c2 = Container.new id: 22

    k.add_container c1
    k.add_container c2

    card = Card.new id: 1
    c1.add_card card
    event_result = k.transfer_by_ids(prev_container_id: 11, next_container_id: 22, card_id: 1)
    expect(event_result[:prev_container].id).to eq 11
    expect(event_result[:next_container].id).to eq 22
    expect(event_result[:transfer]).to be true

    event_result = k.transfer_by_ids(prev_container_id: 22, next_container_id: 11, card_id: 1)
    expect(event_result[:prev_container].id).to eq 22
    expect(event_result[:next_container].id).to eq 11
    expect(event_result[:transfer]).to be true
  end

  it "should transfer and return correctly if the container is the same" do
    k = CardKernel.new
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    k.add_container c1
    k.add_container c2
    card = Card.new id: 1
    c1.add_card card
    event_result = k.transfer_by_ids(prev_container_id: 11, next_container_id: 11, card_id: 1)
    expect(event_result[:prev_container].id).to eq 11
    expect(event_result[:next_container].id).to eq 11
    expect(event_result[:transfer]).to be true
  end

  it "should transfer and return correctly if the card is not found" do
    k = CardKernel.new
    c1 = Container.new id: 11
    c2 = Container.new id: 22
    k.add_container c1
    k.add_container c2
    card = Card.new id: 1
    c1.add_card card
    event_result = k.transfer_by_ids(prev_container_id: 11, next_container_id: 11, card_id: 2)
    expect(event_result[:transfer]).to be false
  end


end
