# AGENTS.md

Agent guidance for working in this repository (`queries` Ruby gem / Rails engine).

## Scope

- Applies to the entire repository root.
- This project is a Ruby gem with a Rails engine and a dummy Rails app at `spec/dummy`.

## Environment Snapshot

- Ruby in CI: `3.4.1` (from `.github/workflows/ci.yml`).
- Tests: RSpec (`rspec-rails`).
- Lint: RuboCop (`rubocop-rails-omakase` via `.rubocop.yml`).
- DB in dummy app: SQLite.

## Source-of-Truth Files

- `Makefile` for common local commands.
- `.github/workflows/ci.yml` for CI-required behavior.
- `.rubocop.yml` for style/linting baseline.
- `spec/spec_helper.rb` and `spec/rails_helper.rb` for test setup.

## Build, Lint, and Test Commands

Prefer `bundle exec` or `make` from repo root.

### Setup

- Install dependencies: `bundle install`
- Setup via Make: `make install`
- Full setup (deps + dummy DB): `make setup`

### Build

- Build gem: `make build`
- Build gem directly: `gem build queries.gemspec`
- Install built gem locally: `make install-local`

### Lint

- Lint (preferred): `make lint`
- Lint (CI formatter): `bin/rubocop -f github`
- Lint direct: `bundle exec rubocop`
- Auto-fix: `make lint-fix` (runs `bundle exec rubocop -A`)
- Lint one file: `bundle exec rubocop lib/queries/base.rb`

### Test

- Full suite (preferred): `make test`
- Full suite direct: `bundle exec rspec`
- Coverage run: `make test-coverage`
- Coverage run direct: `COVERAGE=true bundle exec rspec`

### Run a Single Test (important)

- Single spec file: `bundle exec rspec spec/queries/posts_spec.rb`
- Single example by line: `bundle exec rspec spec/queries/posts_spec.rb:6`
- Single example by ID: `bundle exec rspec spec/queries/posts_spec.rb[1:1]`
- One example + doc format: `bundle exec rspec spec/queries/posts_spec.rb:6 -fd`
- Stop on first failure: `bundle exec rspec --fail-fast`

### Dummy App DB Commands

- Create/migrate dummy DBs: `make db-setup`
- Migrate dummy DB: `make db-migrate`
- Rollback last migration: `make db-rollback`
- Seed dummy DB: `make db-seed`

## Database Safety Rule

- Do not run destructive DB commands automatically.
- Never run `db:drop`, `db:reset`, drop/purge SQL, or equivalent reset without explicit user confirmation.
- Prefer safe alternatives first: `db:migrate`, targeted rollback, or read-only inspection.

## Fast Validation Recipes

- Typical pre-PR check: `make check`.
- If you changed one class, run at least:
  - `bundle exec rubocop <changed_file>`
  - `bundle exec rspec <nearest_spec_file>`
- For CI parity after broad changes:
  - `bin/rubocop -f github`
  - `bundle exec rspec`

## Code Style Guidelines

Follow existing local patterns first, then RuboCop defaults.

### Formatting

- RuboCop Omakase is the style authority.
- Use 2-space indentation.
- Keep methods focused and small where practical.
- Avoid trailing whitespace and pure formatting churn.

### Imports / Requires

- Keep `require` statements at top of file.
- Prefer one require per line.
- Use `require_relative` only where already idiomatic (bootstrapping/gemspec patterns).
- In specs, default to `require "rails_helper"` unless only `spec_helper` is needed.

### Naming Conventions

- Classes/modules: `CamelCase` (e.g., `Queries::Base`).
- Files: `snake_case.rb`, aligned with constants.
- Query classes: explicit, noun-focused names (e.g., `Posts`, `FindPostById`).
- SQL files: `app/queries/sql/<query_class_name>.sql` unless `SQL_FILE` intentionally overrides.
- Constants: `ALL_CAPS` (e.g., `MODEL`, `SQL_FILE`, `VERSION`).

### Types and Data Shapes (Ruby)

- Ruby is dynamic; document expectations through naming and tests.
- Normalize/validate incoming params at boundaries when needed.
- Do not add pseudo-static typing patterns; prefer idiomatic Ruby plus specs.

### Query Layer Conventions

- Common query behavior belongs in `Queries::Base`.
- Keep query entrypoint compatible with `.call(params = {}, sql_file: nil)` unless intentionally redesigned.
- Use parameter sanitization; never interpolate untrusted values into SQL.
- Keep SQL in `.sql` files instead of large inline strings.

### Error Handling

- Raise specific error classes for new failure paths.
- Use actionable messages with file/path context.
- Avoid broad `rescue` without explicit exception classes.
- In specs, prefer explicit error class/message assertions over generic `raise_error`.

### Testing Conventions

- Use `describe` / `context` / `it` with behavior-focused examples.
- Prefer `described_class` for subject under test.
- Keep tests deterministic and isolated.
- Add or update specs for every behavior change.
- For bug fixes, add a failing spec first, then implement the fix.

### Comments and Documentation

- Prefer self-explanatory code over long comments.
- Add comments only for non-obvious constraints/decisions.
- Update `README.md` when public API/usage changes.

## File Placement Guidance

- Library code: `lib/queries/**`.
- Engine wiring: `lib/queries/engine.rb`.
- Dummy app integration surface: `spec/dummy/**`.
- Specs:
  - Library behavior: `spec/lib/**`
  - Query behavior: `spec/queries/**`

## CI Notes

- CI has two jobs: lint + test.
- Test job migrates dummy DB before running RSpec.
- Coverage upload reads `coverage/.resultset.json`.

## Cursor and Copilot Rules

- No `.cursor/rules/` directory found.
- No `.cursorrules` file found.
- No `.github/copilot-instructions.md` file found.
- If any are added later, treat them as higher-priority agent instructions and update this file.

## Agent Workflow Checklist

- Read relevant files before editing and follow local patterns.
- Make the smallest safe change that solves the request.
- Run targeted tests first, then broader checks as needed.
- Run lint on touched Ruby files.
- Summarize changes and list exact verification commands run.
