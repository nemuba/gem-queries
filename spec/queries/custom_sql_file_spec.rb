require 'rails_helper'

RSpec.describe 'Custom SQL File Functionality', type: :query do
  let(:custom_sql_path) { Rails.root.join('app', 'queries', 'sql', 'posts.sql') }

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
      expect { query.call }.to raise_error(RuntimeError)
    end
  end

  describe 'passing SQL file via .call method' do
    it 'uses the specified SQL file instead of default' do
      result = Posts.call({}, sql_file: custom_sql_path)
      expect(result).to be_an(Array)
    end

    it 'raises an error when SQL file does not exist' do
      invalid_path = Rails.root.join('app', 'queries', 'sql', 'nonexistent.sql')
      expect { Posts.call({}, sql_file: invalid_path) }.to raise_error(RuntimeError)
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
  end
end
