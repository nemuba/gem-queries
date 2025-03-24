require 'rails_helper'

RSpec.describe WithoutModel, type: :query do
  let(:query) { described_class.new({}) }


  describe "#call" do
    it "returns an Array" do
      expect(query.call).to be_an(Array)
    end
  end
end
