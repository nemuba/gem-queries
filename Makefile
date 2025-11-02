.PHONY: help install setup test test-coverage lint lint-fix console server clean db-setup db-migrate db-reset release

# Colors for output (using printf format)
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
CYAN := \033[0;36m
MAGENTA := \033[0;35m
RESET := \033[0m
BOLD := \033[1m

# Default target
.DEFAULT_GOAL := help

##@ 🚀 Setup & Installation

install: ## Install dependencies
	@printf "$(BOLD)$(BLUE)📦 Installing dependencies...$(RESET)\n"
	@bundle install
	@printf "$(GREEN)✅ Dependencies installed!$(RESET)\n"

setup: install db-setup ## Initial project setup (install deps + setup database)
	@printf "$(GREEN)✅ Setup complete!$(RESET)\n"

##@ 🧪 Testing

test: ## Run all tests
	@printf "$(BOLD)$(CYAN)🧪 Running tests...$(RESET)\n"
	@bundle exec rspec
	@printf "$(GREEN)✅ Tests completed!$(RESET)\n"

test-coverage: ## Run tests with coverage report
	@printf "$(BOLD)$(CYAN)🧪 Running tests with coverage...$(RESET)\n"
	@COVERAGE=true bundle exec rspec
	@printf "$(GREEN)✅ Coverage report generated in coverage/index.html$(RESET)\n"

test-watch: ## Run tests in watch mode (requires fswatch or entr)
	@printf "$(BOLD)$(CYAN)👀 Watching for changes and running tests...$(RESET)\n"
	@which fswatch > /dev/null 2>&1 || (printf "$(YELLOW)⚠️  fswatch not found. Install with: brew install fswatch$(RESET)\n" && exit 1)
	@fswatch -o lib spec | xargs -n1 -I{} make test

##@ 🔍 Linting & Code Quality

lint: ## Run RuboCop linter
	@printf "$(BOLD)$(MAGENTA)🔍 Running RuboCop...$(RESET)\n"
	@bundle exec rubocop
	@printf "$(GREEN)✅ Linting complete!$(RESET)\n"

lint-fix: ## Run RuboCop with auto-fix
	@printf "$(BOLD)$(MAGENTA)🔧 Running RuboCop with auto-fix...$(RESET)\n"
	@bundle exec rubocop -A
	@printf "$(GREEN)✅ Linting complete!$(RESET)\n"

check: lint test ## Run all checks (lint + test)
	@printf "$(GREEN)✅ All checks passed!$(RESET)\n"

##@ 🗄️  Database

db-setup: ## Setup database for dummy app
	@printf "$(BOLD)$(BLUE)🗄️  Setting up database...$(RESET)\n"
	@cd spec/dummy && bundle exec rails db:create db:migrate RAILS_ENV=test
	@cd spec/dummy && bundle exec rails db:create db:migrate RAILS_ENV=development
	@printf "$(GREEN)✅ Database setup complete!$(RESET)\n"

db-migrate: ## Run migrations for dummy app
	@printf "$(BOLD)$(BLUE)🗄️  Running migrations...$(RESET)\n"
	@cd spec/dummy && bundle exec rails db:migrate
	@printf "$(GREEN)✅ Migrations complete!$(RESET)\n"

db-rollback: ## Rollback last migration
	@printf "$(BOLD)$(BLUE)🗄️  Rolling back migration...$(RESET)\n"
	@cd spec/dummy && bundle exec rails db:rollback
	@printf "$(GREEN)✅ Rollback complete!$(RESET)\n"

db-reset: ## Reset database (drop, create, migrate)
	@printf "$(BOLD)$(YELLOW)🗄️  Resetting database...$(RESET)\n"
	@cd spec/dummy && bundle exec rails db:reset RAILS_ENV=test
	@cd spec/dummy && bundle exec rails db:reset RAILS_ENV=development
	@printf "$(GREEN)✅ Database reset complete!$(RESET)\n"

db-seed: ## Seed database for dummy app
	@printf "$(BOLD)$(BLUE)🌱 Seeding database...$(RESET)\n"
	@cd spec/dummy && bundle exec rails db:seed
	@printf "$(GREEN)✅ Database seeded!$(RESET)\n"

##@ 🚂 Rails Commands

console: ## Open Rails console for dummy app
	@printf "$(BOLD)$(CYAN)🚂 Opening Rails console...$(RESET)\n"
	@cd spec/dummy && bundle exec rails console

server: ## Start Rails server for dummy app
	@printf "$(BOLD)$(CYAN)🚂 Starting Rails server...$(RESET)\n"
	@printf "$(YELLOW)Server will be available at http://localhost:3000$(RESET)\n"
	@cd spec/dummy && bundle exec rails server

routes: ## Show Rails routes for dummy app
	@cd spec/dummy && bundle exec rails routes

##@ 📦 Build & Release

build: ## Build the gem
	@printf "$(BOLD)$(BLUE)📦 Building gem...$(RESET)\n"
	@gem build queries.gemspec
	@printf "$(GREEN)✅ Gem built!$(RESET)\n"

install-local: build ## Build and install gem locally
	@printf "$(BOLD)$(BLUE)📦 Installing gem locally...$(RESET)\n"
	@gem install queries-*.gem
	@printf "$(GREEN)✅ Gem installed locally!$(RESET)\n"

release: ## Release the gem (requires version bump)
	@printf "$(BOLD)$(YELLOW)🚀 Releasing gem...$(RESET)\n"
	@read -p "Enter version (e.g., 1.2.3): " version; \
	sed -i.bak "s/VERSION = .*/VERSION = \"$$version\"/" lib/queries/version.rb; \
	rm lib/queries/version.rb.bak; \
	git add lib/queries/version.rb; \
	git commit -m "Bump version to $$version"; \
	git tag -a v$$version -m "Release v$$version"; \
	make build; \
	printf "$(GREEN)✅ Release v$$version created!$(RESET)\n"; \
	printf "$(YELLOW)Push with: git push origin main --tags$(RESET)\n"; \
	printf "$(YELLOW)Publish with: gem push queries-$$version.gem$(RESET)\n"

##@ 🧹 Cleanup

clean: ## Clean temporary files
	@printf "$(BOLD)$(YELLOW)🧹 Cleaning temporary files...$(RESET)\n"
	@rm -rf coverage/
	@rm -rf spec/dummy/tmp/*
	@rm -rf spec/dummy/log/*
	@rm -rf *.gem
	@rm -rf .bundle/vendor/cache
	@find . -name "*.gem" -type f -delete
	@printf "$(GREEN)✅ Cleanup complete!$(RESET)\n"

clean-all: clean ## Clean everything including bundle cache
	@printf "$(BOLD)$(YELLOW)🧹 Deep cleaning...$(RESET)\n"
	@bundle clean --force
	@rm -rf spec/dummy/node_modules
	@rm -rf spec/dummy/.bundle
	@printf "$(GREEN)✅ Deep cleanup complete!$(RESET)\n"

##@ 📊 Utilities

coverage: test-coverage ## Open coverage report (alias for test-coverage)
	@printf "$(YELLOW)📊 Coverage report available at: file://$(PWD)/coverage/index.html$(RESET)\n"

version: ## Show current gem version
	@grep "VERSION" lib/queries/version.rb | sed 's/.*VERSION = "\(.*\)".*/\1/'

info: ## Show project information
	@printf "$(BOLD)$(BLUE)📋 Project Information$(RESET)\n"
	@printf "$(CYAN)Gem Name:$(RESET) queries\n"
	@printf "$(CYAN)Version:$(RESET) $$(make version)\n"
	@printf "$(CYAN)Ruby Version:$(RESET) $$(ruby -v)\n"
	@printf "$(CYAN)Bundler Version:$(RESET) $$(bundle -v)\n"
	@printf "$(CYAN)Rails Version:$(RESET) $$(cd spec/dummy && bundle exec rails -v 2>/dev/null || echo 'Not available')\n"

##@ ❓ Help

help: ## Show this help message
	@printf "\n"
	@printf "$(BOLD)$(BLUE)╔════════════════════════════════════════════════════════╗$(RESET)\n"
	@printf "$(BOLD)$(BLUE)║$(RESET)  $(BOLD)Queries Gem - Makefile Commands$(RESET)                         $(BOLD)$(BLUE)║$(RESET)\n"
	@printf "$(BOLD)$(BLUE)╚════════════════════════════════════════════════════════╝$(RESET)\n"
	@printf "\n"
	@printf "$(BOLD)$(GREEN)Usage:$(RESET) make $(CYAN)<target>$(RESET)\n"
	@printf "\n"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { \
		printf "  $(CYAN)%-20s$(RESET) %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)
	@printf "\n"
	@printf "$(BOLD)$(YELLOW)💡 Tip:$(RESET) Use $(CYAN)make help$(RESET) to show this message\n"
	@printf "\n"

