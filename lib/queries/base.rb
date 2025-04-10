# frozen_string_literal: true

module Queries
  # Base class for all queries
  # This class is responsible for executing SQL queries
  # and returning the results.
  # @example
  #
  # app/queries/application_query.rb
  # This file contains the base class for all queries
  # class ApplicationQuery < Queries::Base
  # end
  #
  # @example
  # app/queries/sql/list_users_query.sql
  # This file contains the SQL query to be executed
  # Example:
  # SELECT * FROM users WHERE id = :id
  #
  # @example
  # app/queries/list_users_query.rb
  # This file contains the query class that inherits from ApplicationQuery
  # class ListUsersQuery < ApplicationQuery
  #   MODEL = User
  # end
  #
  # @users = ListUsersQuery.new({id: 123}).call
  class Base
    # Method initialize
    # @param params [Hash] the parameters to be used in the query
    # @return [void]
    def initialize(params)
      @params = params
    end

    # Method call
    # @return [Array] the result of the query
    def call
      find_by_sql
    end

    # Method self.call
    # @param params [Hash] the parameters to be used in the query
    # @return [Array] the result of the query
    # @note This method is used to call the query
    # @note It creates a new instance of the class and calls the call method
    # @note This method should be used to execute the query
    def self.call(params = {})
      new(params).call
    end

    private

    attr_reader :params

    # Method model
    # @return [Class] the model class to be used in the query
    # @note This method should be overridden in subclasses
    def model
      self.class::MODEL
    rescue
      nil
    end

    # Method find_by_sql
    # @return [Array] the result of the query
    # @note This method should be use the model class to execute the query
    # @note If the model class is not present, it will execute the query directly
    def find_by_sql
      return model.find_by_sql(query) if model.present?

      ActiveRecord::Base.connection.execute(query)
    end

    # Method root_path
    # @return [String] the path to the SQL file
    # @note This method returns the path to the SQL file
    # @note The SQL file should be in the app/queries/sql folder
    def root_path
      Rails.root.join("app", "queries", "sql")
    end

    # Method filename
    # @return [String] the name of the SQL file
    # @note This method returns the name of the SQL file
    # @note The SQL file name should be the same as the class name in snake_case
    # @note The SQL file should be in the app/queries/sql folder
    def filename
      self.class.name.underscore
    end

    # Method file
    # @return [String] the path to the SQL file
    # @note The SQL file name should be the same as the class name in snake_case
    # @note The SQL file should be in the app/queries/sql folder
    def file
      root_path.join("#{filename}.sql")
    end

    # Method sql
    # @return [String] the SQL query
    # @note This method reads the SQL file and returns its content
    # @note If the file does not exist, it raises an error
    def sql
      if  File.exist?(file)
        File.read(file)
      else
        raise "SQL file not found at folder (#{root_path}) for #{filename}.sql"
      end
    end

    # Method sanitize_params
    # @return [Array] the sanitized parameters
    # @note This method is used to prevent SQL injection
    # @note It uses the ActiveRecord::Base.sanitize_sql_array method
    def sanitize_params
      [ sql ].concat([ params ])
    end

    # Method query
    # @return [String] the sanitized SQL query
    # @note This method uses the ActiveRecord::Base.sanitize_sql_array method
    # @note It uses the sql method to get the SQL query and the sanitize_params method to get the parameters
    # @note It returns the sanitized SQL query
    # @note This method should be used to execute the query
    def query
      ActiveRecord::Base.sanitize_sql_array(sanitize_params)
    end
  end
end
