# Este arquivo deve ser carregado antes de qualquer outro código do aplicativo
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require_relative './dummy/config/environment'

require 'rspec/rails'

# Adicione diretórios de suporte aos caminhos de carga
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Configuração para usar fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Se você estiver usando ActiveRecord
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filtrar linhas de backtrace em relatórios de falha
  config.filter_rails_from_backtrace!
end
