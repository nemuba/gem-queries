<!--
Sync Impact Report:
  Version change: 0.1.0 → 0.2.0
  List of modified principles:
    - III. Comprehensive Testing (TDD) → III. Robust Testing Standards
    - IV. RuboCop for Code Style → IV. High Code Quality Standards
    - V. Performance by Design → V. Stringent Performance Requirements
  Added sections:
    - VI. User Experience Consistency
  Removed sections: None
  Templates requiring updates:
    - .specify/templates/plan-template.md: ⚠ pending
    - .specify/templates/spec-template.md: ⚠ pending
    - .specify/templates/tasks-template.md: ⚠ pending
    - .specify/templates/commands/*.md: ⚠ pending
  Follow-up TODOs: None
-->
# Ruby Queries Gem Constitution

## Core Principles

### I. Explicit Query Design
Every feature involving data retrieval MUST be implemented using explicit query objects/classes, typically inheriting from `Queries::Base`. Query objects must encapsulate specific data retrieval logic, parameters, and filtering.

### II. Database Agnostic SQL
All SQL queries MUST be written with consideration for compatibility across PostgreSQL and Oracle, favoring standard SQL features and Common Table Expressions (CTEs) for complexity. Direct database-specific syntax should be avoided unless strictly necessary and explicitly justified. Dangerous DDL operations (e.g., `DROP TABLE`) are strictly prohibited in application code.

### III. Robust Testing Standards
All new features, enhancements, and bug fixes MUST be accompanied by comprehensive automated tests, including unit, integration, and where appropriate, end-to-end tests. A strict Test-Driven Development (TDD) approach is mandatory: tests are written, reviewed, expected to fail, and then the implementation is developed to make them pass. The Red-Green-Refactor cycle is strictly enforced for all development. RSpec is the mandated testing framework. Test coverage targets MUST be maintained as defined in project configurations.

### IV. High Code Quality Standards
Code MUST adhere to high quality standards, encompassing readability, maintainability, and clarity. This includes strict adherence to the project's `.rubocop.yml` configuration for Ruby code style and linting, and employing best practices such as descriptive naming, modular design, and minimizing complexity. Automated code formatting tools (e.g., `bundle exec rubocop -A`) MUST be used. All code MUST pass static analysis and linting checks before merging.

### V. Stringent Performance Requirements
Performance is a critical non-functional requirement. All features MUST meet predefined performance metrics, particularly regarding data retrieval and processing efficiency. This includes actively identifying and resolving N+1 query issues, optimizing complex algorithms, and leveraging database capabilities (e.g., indexes, query optimization) where appropriate. Performance regression testing MUST be part of the CI pipeline.

### VI. User Experience Consistency
All user-facing interactions and interfaces, whether through CLI, APIs, or integration points, MUST maintain a consistent and predictable experience. This includes consistent error handling, input/output formats (e.g., JSON, human-readable text), intuitive parameter usage, and clear documentation. Any changes impacting the user experience MUST be documented as breaking changes in major version increments.

## Development Guidelines

- **Command Execution**: All gem-related commands (e.g., testing, linting) MUST be executed using `bundle exec` to ensure correct dependency resolution.
- **Makefile Usage**: The `Makefile` at the repository root serves as the primary interface for common development tasks (e.g., `make install`, `make test`, `make lint`). Developers MUST familiarize themselves with its commands.
- **Naming Conventions**: Ruby files MUST follow `snake_case.rb` naming. Classes and modules MUST follow `CamelCase`.
- **SQL File Placement**: Complex SQL queries MUST be externalized into `.sql` files located under `app/queries/sql/` unless an explicit override is documented.
- **Parameter Sanitization**: Direct interpolation of untrusted values into SQL queries is strictly forbidden. All parameters MUST be properly sanitized or bound to prevent SQL injection vulnerabilities.

## Release Process

- **Distribution**: New versions of the gem are distributed via RubyGems.
- **Versioning**: Semantic Versioning (MAJOR.MINOR.PATCH) MUST be rigorously applied. Breaking changes (MAJOR), new features (MINOR), and bug fixes/patches (PATCH) must be clearly identified.
- **Quality Gates**: All code changes MUST be submitted via Pull Requests. Passing Continuous Integration (CI) checks, including linting and automated tests, is a mandatory prerequisite for merging.
- **Documentation**: `README.md` and `CHANGELOG.md` MUST be updated to reflect significant changes, new features, and breaking changes prior to any public release.

## Governance

This Constitution serves as the foundational governance document for the "Ruby Queries Gem" project, outlining the non-negotiable principles and guidelines for its development and evolution.

- **Amendments**: Any proposed amendments to this Constitution MUST undergo a formal review process, requiring consensus from the core maintainer team. A clear rationale for the change and consideration of its impact MUST be provided.
- **Compliance Verification**: All Pull Requests and code reviews MUST actively verify compliance with the principles and guidelines articulated herein. Deviations MUST be justified and approved by maintainers.
- **Runtime Guidance**: The `AGENTS.md` file provides detailed, dynamic guidance for agents operating within this project, complementing the static principles defined in this Constitution.

**Version**: 0.2.0 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-05
