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
    # @param sql_file [String, nil] optional path to SQL file to use instead of default
    # @return [void]
    def initialize(params, sql_file: nil)
      @params = normalize_input_params(params)
      @sql_file = sql_file
    end

    # Method call
    # @return [Array] the result of the query
    def call
      find_by_sql
    end

    # Method self.call
    # @param params [Hash] the parameters to be used in the query
    # @param sql_file [String, nil] optional path to SQL file to use instead of default
    # @return [Array] the result of the query
    # @note This method is used to call the query
    # @note It creates a new instance of the class and calls the call method
    # @note This method should be used to execute the query
    def self.call(params = nil, sql_file: nil, **keyword_params)
      merged_params = if keyword_params.empty?
                        params
      else
                        normalize_params_input(params).merge(keyword_params)
      end

      new(merged_params, sql_file: sql_file).call
    end

    private

    attr_reader :params, :sql_file

    def self.normalize_params_input(value)
      return {} if value.nil?
      return value if value.is_a?(Hash)
      if value.respond_to?(:to_h)
        coerced = value.to_h
        return coerced if coerced.is_a?(Hash)
      end

      raise ArgumentError, "params must be a Hash-like object or nil"
    end

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
    # @note Can be overridden by passing sql_file to initialize/call or by setting SQL_FILE constant
    def file
      if sql_file.present?
        sql_file
      elsif self.class.const_defined?(:SQL_FILE, false)
        self.class::SQL_FILE
      else
        root_path.join("#{filename}.sql")
      end
    end

    def file_source
      return "runtime_override" if sql_file.present?
      return "SQL_FILE" if self.class.const_defined?(:SQL_FILE, false)

      "default"
    end

    def base_sql_folder_for_message
      file_source == "default" ? root_path.to_s : "n/a"
    end

    def required_param_names
      sql.scan(/(?<!:):([A-Za-z_][A-Za-z0-9_]*)/).flatten.uniq.sort
    end

    def normalized_param_keys
      params.keys.map(&:to_s).uniq.sort
    end

    def validate_required_params!
      missing = required_param_names - normalized_param_keys
      return if missing.empty?

      missing_list = missing.join(",")
      received_list = normalized_param_keys.join(",")
      raise Errors::MissingRequiredParamsError,
            "Missing required params for #{self.class.name}: missing=[#{missing_list}] received=[#{received_list}]"
    end

    # Method sql
    # @return [String] the SQL query
    # @note This method reads the SQL file and returns its content
    # @note If the file does not exist, it raises an error
    def sql
      if File.exist?(file)
        File.read(file)
      else
        raise Errors::SqlFileNotFoundError,
              "SQL file not found for #{self.class.name}: source=#{file_source} attempted_path=#{file} " \
              "base_sql_folder=#{base_sql_folder_for_message}"
      end
    end

    # Method sanitize_params
    # @return [Array] the sanitized parameters
    # @note This method is used to prevent SQL injection
    # @note It uses the ActiveRecord::Base.sanitize_sql_array method
    def sanitize_params
      bind_params = params.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = value
      end

      [ sql, bind_params ]
    end

    # Method query
    # @return [String] the sanitized SQL query
    # @note This method uses the ActiveRecord::Base.sanitize_sql_array method
    # @note It uses the sql method to get the SQL query and the sanitize_params method to get the parameters
    # @note It returns the sanitized SQL query
    # @note This method should be used to execute the query
    def query
      validate_required_params!
      ActiveRecord::Base.sanitize_sql_array(sanitize_params)
    end

    def normalize_input_params(value)
      self.class.normalize_params_input(value)
    end
  end
end
