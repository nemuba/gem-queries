require 'rails_helper'

RSpec.describe WithoutModel, type: :query do
  let(:query) { described_class.new({}) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
  end

  describe "#call" do
    it "returns an Array" do
      allow(logger).to receive(:info)

      expect(query.call).to be_an(Array)
    end

    it "does not break query execution when logger fails" do
      allow(logger).to receive(:info).and_raise(StandardError, "logger backend unavailable")

      expect(query.call).to be_an(Array)
    end
  end
end
