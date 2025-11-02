source "https://rubygems.org"

# Specify your gem's dependencies in queries.gemspec.
gemspec

gem "puma"

gem "sqlite3"

gem "propshaft"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
gem "debug", ">= 1.0.0"

# Ruby LSP for editor support
gem "ruby-lsp", require: false

group :test do
  gem "rspec-rails", "~> 8.0"
  gem "simplecov", require: false
end
