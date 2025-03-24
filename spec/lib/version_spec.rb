require 'rails_helper'
require 'queries/version'

RSpec.describe Queries do
  describe 'VERSION' do
    it 'tem uma constante de versão definida' do
      expect(Queries::VERSION).not_to be_nil
    end

    it 'a versão é uma string' do
      expect(Queries::VERSION).to be_a(String)
    end

    it 'segue o formato de versionamento semântico (X.Y.Z)' do
      expect(Queries::VERSION).to match(/^\d+\.\d+\.\d+$/)
    end
  end
end
