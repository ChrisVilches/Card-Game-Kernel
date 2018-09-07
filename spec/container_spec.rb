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

  describe "nested containers" do

    before(:each) do
      @k = CardKernel.new
      @main = @k.create_container [:main]
      @other = @k.create_container [:main, :other]
      @computer = @k.create_container [:main, :computer]
      @next_ = @k.create_container [:main, :other, :next]
      @hello = @k.create_container [:main, :other, :hello]
    end

    describe "event trigger propagation" do
      before(:each) do
        global_hooks = GlobalHooks.new
        global_hooks.append_hook(:pre, event_name: :visit, fn: lambda { |args|
          args[:card].set_attributes({ visited: true })
          return true
        })

        @card_array = Array.new

        10.times do |i|
          @card_array << Card.new(id: i, global_hooks: global_hooks)
        end

        @main.add_card @card_array[0]
        @main.add_card @card_array[1]

        @other.add_card @card_array[2]
        @computer.add_card @card_array[3]

        @next_.add_card @card_array[4]
        @next_.add_card @card_array[5]

        @hello.add_card @card_array[6]
        @hello.add_card @card_array[7]
      end

      it "should propagate event triggers when recursive option is set to true" do
        @other.trigger_event(event: :visit, recursive: true)
        expect(@card_array[0].attributes).to_not have_key(:visited)
        expect(@card_array[1].attributes).to_not have_key(:visited)
        expect(@card_array[2].attributes).to have_key(:visited)
        expect(@card_array[3].attributes).to_not have_key(:visited)
        expect(@card_array[4].attributes).to have_key(:visited)
        expect(@card_array[5].attributes).to have_key(:visited)
        expect(@card_array[6].attributes).to have_key(:visited)
        expect(@card_array[7].attributes).to have_key(:visited)
        expect(@card_array[8].attributes).to_not have_key(:visited)
        expect(@card_array[9].attributes).to_not have_key(:visited)
      end

      it "should not propagate event triggers when recursive option is set to false" do
        @other.trigger_event(event: :visit)
        expect(@card_array[0].attributes).to_not have_key(:visited)
        expect(@card_array[1].attributes).to_not have_key(:visited)
        expect(@card_array[2].attributes).to have_key(:visited)
        expect(@card_array[3].attributes).to_not have_key(:visited)
        expect(@card_array[4].attributes).to_not have_key(:visited)
        expect(@card_array[5].attributes).to_not have_key(:visited)
        expect(@card_array[6].attributes).to_not have_key(:visited)
        expect(@card_array[7].attributes).to_not have_key(:visited)
        expect(@card_array[8].attributes).to_not have_key(:visited)
        expect(@card_array[9].attributes).to_not have_key(:visited)
      end

    end


    it "should create nested containers" do
      expect(@k.containers.size).to eq 1
      expect(@k.containers[:main].containers.size).to eq 2
      expect(@k.containers[:main].containers[:other].containers.size).to eq 2
      expect(@k.containers[:main].containers[:computer].containers.size).to eq 0
    end

    it "should not create nested containers if there's an error in the path" do
      @k = CardKernel.new
      @k.create_container [:main]
      @k.create_container [:main, :other]
      expect{ @k.create_container [:main, :hello, :world] }.to raise_error ContainerNotFound
    end

    it "should find nested containers correctly" do
      expect(@k.find_container [:main]).to be @main
      expect(@k.find_container [:main, :other]).to be @other
      expect(@k.find_container [:main, :computer]).to be @computer
      expect(@k.find_container [:main, :other, :next]).to be @next_
      expect(@k.find_container [:main, :other, :hello]).to be @hello
    end

      it "should raise an error when trying to find a nested container that doesn't exist" do
      expect{ @k.find_container [:mainx] }.to raise_error ContainerNotFound
      expect{ @k.find_container [:main, :other, :a] }.to raise_error ContainerNotFound

    end
  end



end
