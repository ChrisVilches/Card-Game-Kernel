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
    a = k.create_container [:main]
    b = k.create_container [:main, :hello]
    c = k.create_container [:main, :world]

    card = Card.new id: 1
    a.add_card card
    
    event_result = k.transfer_by_ids(prev_container_id: [:main], next_container_id: [:main, :hello], card_id: 1)
    
    expect(event_result[:prev_container]).to be a
    expect(event_result[:next_container]).to be b
    expect(event_result[:transfer]).to be true

    event_result = k.transfer_by_ids(prev_container_id: [:main, :hello], next_container_id: [:main, :world], card_id: 1)
    expect(event_result[:prev_container]).to be b
    expect(event_result[:next_container]).to be c
    expect(event_result[:transfer]).to be true
  end

  it "should transfer and return correctly if the container is the same" do
    k = CardKernel.new
    a = k.create_container [:main]

    card = Card.new id: 1
    a.add_card card
    
    event_result = k.transfer_by_ids(prev_container_id: [:main], next_container_id: [:main], card_id: 1)
    
    expect(event_result[:prev_container]).to be a
    expect(event_result[:next_container]).to be a
    expect(event_result[:transfer]).to be true

  end

  it "should transfer and return correctly if the card is not found" do
    k = CardKernel.new
    a = k.create_container [:main]

    card = Card.new id: 1
    a.add_card card
    
    event_result = k.transfer_by_ids(prev_container_id: [:main], next_container_id: [:main], card_id: 3)
    expect(event_result[:transfer]).to be false
  end


end
