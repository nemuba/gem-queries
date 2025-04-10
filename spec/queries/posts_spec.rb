require 'rails_helper'

RSpec.describe Posts, type: :query do
  subject { described_class }
  describe "#call" do
    it "returns an Array" do
      expect(subject.call).to be_an(Array)
    end

    it "returns one or more records" do
      3.times { Post.create(title: "Test Post", description: "Test Description") }
      expect(subject.call).to be_present
    end
  end
end
