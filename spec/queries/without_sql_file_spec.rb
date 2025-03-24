require 'rails_helper'

RSpec.describe WithoutSqlFile, type: :query do
  let(:query) { described_class.new({}) }

  describe "#call" do
    it "should raise an error" do
      expect { query.call }.to raise_error
    end
  end
end
