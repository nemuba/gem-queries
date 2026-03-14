require 'rails_helper'

RSpec.describe WithoutSqlFile, type: :query do
  let(:query) { described_class.new({}) }

  describe "#call" do
    it "raises a custom SQL file not found error" do
      expect { query.call }.to raise_error(
        Queries::Errors::SqlFileNotFoundError,
        /SQL file not found for WithoutSqlFile/
      )
    end
  end
end
