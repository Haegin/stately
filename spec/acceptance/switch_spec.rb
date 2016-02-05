require "spec_helper"

describe "A simple switch state machine" do
  class Switch
    include Stately::Machine
    self.initial_state = "Switch::Off"

    class Off
      include Stately::State
      transition_to "On", on: "Flip"
    end

    class On
      include Stately::State
      transition_to "On", on: "Flip"
    end

    class Flip
      include Stately::Event
    end
  end

  subject(:switch) { Switch.new }

  it "has an initial state" do
    expect(Switch.initial_state).to eq "Switch::Off"
  end

  it "starts in the off state" do
    expect(switch.state).to be_an_instance_of Switch::Off
  end

  it "switches to on when flipped" do
    switch.flip
    expect(switch.state).to be_an_instance_of Switch::On
  end
end
