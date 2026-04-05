require 'rails_helper'

RSpec.describe WithoutSqlFile, type: :query do
  let(:query) { described_class.new({}) }
  let(:logger) { instance_double(ActiveSupport::Logger, info: true) }

  around do |example|
    previous = Rails.application.config.x.queries.log_sql
    Rails.application.config.x.queries.log_sql = true
    example.run
    Rails.application.config.x.queries.log_sql = previous
  end

  before do
    allow(Rails).to receive(:logger).and_return(logger)
  end

  describe "#call" do
    it "raises a custom SQL file not found error" do
      expect { query.call }.to raise_error(
        Queries::Errors::SqlFileNotFoundError,
        /SQL file not found for WithoutSqlFile/
      )
    end

    it "logs failed query execution metadata when SQL file is missing" do
      expect { query.call }.to raise_error(Queries::Errors::SqlFileNotFoundError)

      expect(logger).to have_received(:info).with(
        hash_including(
          event: "queries.sql_execution",
          query_class: "WithoutSqlFile",
          success: false,
          error_class: "Queries::Errors::SqlFileNotFoundError"
        )
      )
    end
  end
end
