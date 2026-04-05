require 'rails_helper'

RSpec.describe 'Custom SQL File Functionality', type: :query do
  let(:custom_sql_path) { Rails.root.join('app', 'queries', 'sql', 'posts.sql') }
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

  describe 'default behavior' do
    it 'loads SQL from app/queries/sql/class_name.sql by default' do
      expect(Posts.call).to be_an(Array)
    end
  end

  describe 'passing SQL file via initializer' do
    it 'uses the specified SQL file instead of default' do
      query = Posts.new({}, sql_file: custom_sql_path)
      result = query.call
      expect(result).to be_an(Array)
    end

    it 'raises an error when SQL file does not exist' do
      invalid_path = Rails.root.join('app', 'queries', 'sql', 'nonexistent.sql')
      query = Posts.new({}, sql_file: invalid_path)
      expect { query.call }.to raise_error(
        Queries::Errors::SqlFileNotFoundError,
        /source=runtime_override attempted_path=.*nonexistent\.sql base_sql_folder=n\/a/
      )
    end

    it 'includes runtime_override source metadata in SQL log' do
      query = Posts.new({}, sql_file: custom_sql_path)

      query.call

      expect(logger).to have_received(:info).with(
        hash_including(
          event: 'queries.sql_execution',
          query_class: 'Posts',
          sql_source: 'runtime_override',
          sql_file: custom_sql_path.to_s
        )
      )
    end
  end

  describe 'passing SQL file via .call method' do
    it 'uses the specified SQL file instead of default' do
      result = Posts.call({}, sql_file: custom_sql_path)
      expect(result).to be_an(Array)
    end

    it 'raises SqlFileNotFoundError with runtime override metadata when SQL file does not exist' do
      invalid_path = Rails.root.join('app', 'queries', 'sql', 'nonexistent.sql')

      expect { Posts.call({}, sql_file: invalid_path) }.to raise_error(
        Queries::Errors::SqlFileNotFoundError,
        /source=runtime_override attempted_path=.*nonexistent\.sql base_sql_folder=n\/a/
      )
    end
  end

  describe 'missing SQL file metadata' do
    it 'includes default source metadata for missing default SQL file' do
      expect { WithoutSqlFile.call }.to raise_error(
        Queries::Errors::SqlFileNotFoundError,
        /source=default attempted_path=.*without_sql_file\.sql base_sql_folder=.*app\/queries\/sql/
      )
    end

    it 'includes SQL_FILE source metadata for missing SQL_FILE path' do
      invalid_sql_file_query = Class.new(ApplicationQuery)
      invalid_sql_file_query.const_set(:MODEL, Post)
      invalid_sql_file_query.const_set(:SQL_FILE, Rails.root.join('app', 'queries', 'sql', 'missing_from_constant.sql'))
      stub_const('InvalidSqlFileQuery', invalid_sql_file_query)

      expect { invalid_sql_file_query.call }.to raise_error(
        Queries::Errors::SqlFileNotFoundError,
        /source=SQL_FILE attempted_path=.*missing_from_constant\.sql base_sql_folder=n\/a/
      )
    end
  end

  describe 'using SQL_FILE class constant' do
    before(:all) do
      # Create a query class with SQL_FILE constant
      class QueryWithConstant < ApplicationQuery
        MODEL = Post
        SQL_FILE = Rails.root.join('app', 'queries', 'sql', 'posts.sql')
      end
    end

    after(:all) do
      Object.send(:remove_const, :QueryWithConstant) if defined?(QueryWithConstant)
    end

    it 'uses the SQL_FILE constant' do
      result = QueryWithConstant.call
      expect(result).to be_an(Array)
    end

    it 'sql_file parameter overrides SQL_FILE constant' do
      alternative_sql = Rails.root.join('app', 'queries', 'sql', 'posts.sql')
      result = QueryWithConstant.call({}, sql_file: alternative_sql)
      expect(result).to be_an(Array)
    end
  end

  describe 'priority order' do
    before(:all) do
      # Create a query class with SQL_FILE constant
      class PriorityTestQuery < ApplicationQuery
        MODEL = Post
        SQL_FILE = Rails.root.join('app', 'queries', 'sql', 'posts.sql')
      end
    end

    after(:all) do
      Object.send(:remove_const, :PriorityTestQuery) if defined?(PriorityTestQuery)
    end

    it 'prefers sql_file parameter over SQL_FILE constant' do
      custom_file = Rails.root.join('app', 'queries', 'sql', 'posts.sql')
      result = PriorityTestQuery.call({}, sql_file: custom_file)
      expect(result).to be_an(Array)
    end

    it 'uses SQL_FILE constant when sql_file parameter is nil' do
      result = PriorityTestQuery.call
      expect(result).to be_an(Array)
    end

    it 'uses default behavior when neither sql_file nor SQL_FILE is set' do
      result = Posts.call
      expect(result).to be_an(Array)
    end

    it 'logs default source metadata when using class name SQL lookup' do
      Posts.call

      expect(logger).to have_received(:info).with(
        hash_including(
          query_class: 'Posts',
          sql_source: 'default'
        )
      )
    end

    it 'logs SQL_FILE source metadata when SQL_FILE constant is used' do
      sql_file_query = Class.new(ApplicationQuery)
      sql_file_query.const_set(:MODEL, Post)
      sql_file_query.const_set(:SQL_FILE, Rails.root.join('app', 'queries', 'sql', 'posts.sql'))
      stub_const('SqlFileSourceQuery', sql_file_query)

      sql_file_query.call

      expect(logger).to have_received(:info).with(
        hash_including(
          query_class: 'SqlFileSourceQuery',
          sql_source: 'SQL_FILE'
        )
      )
    end
  end

  describe 'error hierarchy compatibility' do
    it 'keeps custom errors compatible with RuntimeError and StandardError' do
      expect(Queries::Errors::SqlFileNotFoundError).to be < RuntimeError
      expect(Queries::Errors::SqlFileNotFoundError).to be < StandardError

      expect(Queries::Errors::MissingRequiredParamsError).to be < RuntimeError
      expect(Queries::Errors::MissingRequiredParamsError).to be < StandardError
    end
  end
end
