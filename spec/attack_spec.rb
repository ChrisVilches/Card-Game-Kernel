require_relative '../container'
require_relative '../card'

class AttackerCard < Card

  def initialize(id:, global_hooks: nil)
    super(id: id, global_hooks: global_hooks)
    set_attributes({ hp: 100 })
    on(:receive_attack, lambda { |args|

      self.attributes[:hp] = self.attributes[:hp] - args[:damage]
      return {
        current_hp: self.attributes[:hp]
      }
    })

    on(:receive_attack_counterattack, lambda { |args|

      multiplier = args[:damage_multiplier]
      multiplier = 1 if multiplier.nil?

      self.attributes[:hp] = self.attributes[:hp] - (args[:damage] * multiplier)
      args[:attacker_card].trigger_event(:receive_attack, { damage: 3 })
      return {
        current_hp: self.attributes[:hp]
      }
    })

  end

end

describe Container do
  it "receives attack" do
    card = AttackerCard.new id: 11
    expect(card.attributes[:hp]).to eq 100
    card.trigger_event(:receive_attack, { damage: 13 })
    expect(card.attributes[:hp]).to eq 87
  end

  it "receives attack and counterattacks" do
    card1 = AttackerCard.new id: 11
    card2 = AttackerCard.new id: 22
    expect(card1.attributes[:hp]).to eq 100
    expect(card2.attributes[:hp]).to eq 100
    card1.trigger_event(:receive_attack_counterattack, {
      damage: 13,
      attacker_card: card2
    })
    expect(card1.attributes[:hp]).to eq 87
    expect(card2.attributes[:hp]).to eq 97
  end

  it "receives attack and counterattacks, but with a global multiplier, affecting only the attack (not counterattack)" do

    global_hooks = GlobalHooks.new
    global_hooks.append_hook(:pre, event_name: :receive_attack_counterattack, fn: lambda { |args| return { damage_multiplier: 2 } })
    global_hooks.append_hook(:pre, event_name: :this_shouldnt_execute, fn: lambda { |args| puts "+-+-+-+-+-+-+-+-+-"; return false })

    card1 = AttackerCard.new(id: 11, global_hooks: global_hooks)
    card2 = AttackerCard.new(id: 22, global_hooks: global_hooks)
    expect(card1.attributes[:hp]).to eq 100
    expect(card2.attributes[:hp]).to eq 100
    card1.trigger_event(:receive_attack_counterattack, {
      damage: 13,
      attacker_card: card2
    })
    expect(card1.attributes[:hp]).to eq 74
    expect(card2.attributes[:hp]).to eq 97
  end


end
