require_relative '../../container'
require_relative '../../card'
require_relative '../../card_kernel'

class AttackBlockerCard < Card

  def initialize(id:, global_hooks: nil)
    super(id: id, global_hooks: global_hooks)
    set_attributes({ hp: 100 })
    on(:receive_attack, lambda { |args|

      self.attributes[:hp] = self.attributes[:hp] - args[:damage]
      return {
        current_hp: self.attributes[:hp]
      }
    })

    # It's blocked by a global hook
  end

end


describe Card do

  it "blocks events when returning false from a global hook" do

    global_hooks = GlobalHooks.new
    global_hooks.append_hook(:pre, event_name: :receive_attack, fn: lambda { |args|

      if args[:damage] % 5 == 0
        return false
      end

      return true
    })

    k = CardKernel.new
    a = k.create_container [:a]
    b = k.create_container [:a, :b]

    card1 = AttackerCard.new(id: 11, global_hooks: global_hooks)
    card2 = AttackerCard.new(id: 22, global_hooks: global_hooks)

    a.add_card card1
    b.add_card card2

    expect(card1.attributes[:hp]).to eq 100
    expect(card2.attributes[:hp]).to eq 100

    a.trigger_event(event: :receive_attack, arguments: { damage: 13 })

    expect(card1.attributes[:hp]).to eq 87
    expect(card2.attributes[:hp]).to eq 100

    a.trigger_event(event: :receive_attack, arguments: { damage: 15 })

    expect(card1.attributes[:hp]).to eq 87
    expect(card2.attributes[:hp]).to eq 100

    a.trigger_event(event: :receive_attack, arguments: { damage: 16 })

    expect(card1.attributes[:hp]).to eq 71
    expect(card2.attributes[:hp]).to eq 100


  end


end
