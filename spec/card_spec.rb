require_relative '../card'
require_relative '../card_kernel'
require_relative '../container'


class DataSenderCard < Card
  def initialize(id: 1, set_data_callback: nil, get_data_callback: nil)
    super

    data_set_lambda = ->(args) {
      set_data(action: "banana", arguments: {}) if args[:type] == :fruit
      set_data(action: "car", arguments: {}) if args[:type] == :vehicle
    }

    data_get_lambda = ->(args) {
      get_data
    }

    on :something_happens, data_set_lambda
    on :should_get_data, data_get_lambda
  end

  def register_event_handler_incorrectly
    on :wrong_event_handler, lambda { return }
  end

  def register_hook_incorrectly
    on :pre, :wrong_event_handler, lambda { return }
  end

  def register_event_handler_correctly
    on :wrong_event_handler, lambda { |args| return }
  end

  def register_hook_correctly
    on :pre, :wrong_event_handler, lambda { |args| return }
  end
end



describe Card do

  it "should raise an error if data callbacks have a wrong arity" do

    no_arg = lambda { return }
    one_arg = lambda { |a| return }
    two_arg = lambda { |a, b| return }

    expect {DataSenderCard.new(set_data_callback: one_arg, get_data_callback: nil)}.to raise_error ArgumentError
    expect {DataSenderCard.new(set_data_callback: nil, get_data_callback: one_arg)}.to raise_error ArgumentError
    DataSenderCard.new(set_data_callback: two_arg, get_data_callback: no_arg)
  end

  describe "arity validators" do

    before(:each) do
      @data_card = DataSenderCard.new(id: 1)
    end

    it "should raise an error when registering an event handler without a parameter" do
      expect { @data_card.register_event_handler_incorrectly }.to raise_error ArgumentError
    end

    it "should raise an error when registering a hook without a parameter" do
      expect { @data_card.register_hook_incorrectly }.to raise_error ArgumentError
    end

    it "should not raise an error when registering an event handler with a parameter" do
      @data_card.register_event_handler_correctly
    end

    it "should not raise an error when registering a hook with a parameter" do
      @data_card.register_hook_correctly
    end
  end

  it "sends data to its data callback successfully" do

    data_store = Hash.new

    data_card = DataSenderCard.new(
      id: 1,
      set_data_callback: lambda { |action, args| data_store[:string] = "Hi #{action}"; return; },
      get_data_callback: lambda { data_store }
    )

    data_card.trigger_event(event: :something_happens, arguments: { type: :fruit })
    retrieved_data_store = data_card.trigger_event(event: :should_get_data, arguments: {})
    expect(retrieved_data_store[:string]).to eq "Hi banana"

    data_card.trigger_event(event: :something_happens, arguments: { type: :vehicle })
    retrieved_data_store = data_card.trigger_event(event: :should_get_data, arguments: {})
    expect(retrieved_data_store[:string]).to eq "Hi car"

  end

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
