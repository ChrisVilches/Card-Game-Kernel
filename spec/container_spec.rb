require_relative '../container'
require_relative '../card'
require_relative '../card_kernel'

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
  
  it "should create nested containers" do
    k = CardKernel.new
    k.create_container [:main]    
    k.create_container [:main, :other]
    k.create_container [:main, :computer]
    k.create_container [:main, :other, :next]
    k.create_container [:main, :other, :hello]
    
    expect(k.containers.size).to eq 1
    expect(k.containers[:main].containers.size).to eq 2
    expect(k.containers[:main].containers[:other].containers.size).to eq 2
    expect(k.containers[:main].containers[:computer].containers.size).to eq 0
  end
  
  it "should create nested containers with correct IDs" do
    k = CardKernel.new
    k.create_container [:main]    
    k.create_container [:main, :other]
    k.create_container [:main, :other, :hello]
    
    expect(k.find_container([:main]).id).to eq [:main]
    expect(k.find_container([:main, :other]).id).to eq [:main, :other]
    expect(k.find_container([:main, :other, :hello]).id).to eq [:main, :other, :hello]
  end
  
  it "should not create nested containers if there's an error in the path" do
    k = CardKernel.new
    k.create_container [:main]    
    k.create_container [:main, :other]
    expect{ k.create_container [:main, :hello, :world] }.to raise_error ContainerNotFound
  end
  
  it "should find nested containers correctly" do
    k = CardKernel.new
    main = k.create_container [:main]    
    other = k.create_container [:main, :other]
    computer = k.create_container [:main, :computer]
    next_ = k.create_container [:main, :other, :next]
    hello = k.create_container [:main, :other, :hello]
    
    expect(k.find_container [:main]).to be main
    expect(k.find_container [:main, :other]).to be other
    expect(k.find_container [:main, :computer]).to be computer
    expect(k.find_container [:main, :other, :next]).to be next_
    expect(k.find_container [:main, :other, :hello]).to be hello
  end
  
    it "should raise an error when trying to find a nested container that doesn't exist" do
    k = CardKernel.new
    k.create_container [:main]    
    k.create_container [:main, :other]
    k.create_container [:main, :computer]
    
    expect{ k.find_container [:mainx] }.to raise_error ContainerNotFound
    expect{ k.find_container [:main, :other, :a] }.to raise_error ContainerNotFound

  end


end
