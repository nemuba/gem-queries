require 'rails_helper'

RSpec.describe Posts, type: :query do
  let(:query) { described_class.new({}) }

  describe "#call" do
    it "returns an Array" do
      expect(query.call).to be_an(Array)
    end

    it "returns one or more records" do
      3.times { Post.create(title: "Test Post", description: "Test Description") }
      expect(query.call).to be_present
    end
  end
end
