require_relative '../container'
require_relative '../card'
require_relative '../card_kernel'

describe CardKernel do
  it "should transfer_by_ids correctly" do

    k = CardKernel.new
    a = k.create_container [:main]
    b = k.create_container [:main, :hello]
    c = k.create_container [:main, :world]

    card = Card.new id: 1
    a.add_card card    
    
    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 0
    expect(c.cards.length).to eq 0
    
    k.transfer_by_ids(prev_container_id: [:main], next_container_id: [:main, :world], card_id: 1)
    
    expect(a.cards.length).to eq 0
    expect(b.cards.length).to eq 0
    expect(c.cards.length).to eq 1
  end

  it "should transfer_by_id correctly if card doesn't exist" do

    k = CardKernel.new
    a = k.create_container [:main]
    b = k.create_container [:main, :hello]
    c = k.create_container [:main, :world]

    card = Card.new id: 1
    a.add_card card    
    
    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 0
    expect(c.cards.length).to eq 0
    
    k.transfer_by_ids(prev_container_id: [:main], next_container_id: [:main, :world], card_id: 2)
    
    expect(a.cards.length).to eq 1
    expect(b.cards.length).to eq 0
    expect(c.cards.length).to eq 0
  end

end
