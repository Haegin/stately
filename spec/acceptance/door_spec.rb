require "spec_helper"

describe "A security door" do
  class Door
    include Stately::Machine
    self.initial_state = "Door::Closed"

    attr_writer :night
    def night?
      !!@night
    end

    class Closed
      include Stately::State
      transition to: "Door::Opened", on: "Door::Open", unless:  proc { |door| door.night? }
    end

    class Opened
      include Stately::State
      transition to: "Door::Closed", on: "Door::Close"
    end

    class Open
      include Stately::Event
    end

    class Close
      include Stately::Event
    end
  end

  subject(:door) { Door.new }

  it "can be opened" do
    door.open
    expect(door.state).to be_an_instance_of Door::Opened
  end

  it "can be closed" do
    door.open
    door.close
    expect(door.state).to be_an_instance_of Door::Closed
  end

  it "can't be opened at night" do
    expect(door.can_open?).to be_truthy
    door.night = true
    expect(door.can_open?).to be_falsey
  end

  it "returns false if a transition fails" do
    door.night = true
    expect(door.open).to eq false
  end
end
