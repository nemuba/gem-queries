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
      started_at = current_monotonic_time
      executed_sql = query
      result = find_by_sql(executed_sql)
      log_sql_execution(sql_text: executed_sql, started_at: started_at, success: true)
      result
    rescue StandardError => e
      log_sql_execution(sql_text: safe_sql_for_logging(executed_sql), started_at: started_at, success: false, error: e)
      raise
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
    def find_by_sql(sql_text)
      return model.find_by_sql(sql_text) if model.present?

      ActiveRecord::Base.connection.execute(sql_text)
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

    def current_monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def sql_logging_enabled?
      app_config = Rails.application.config.x.queries.log_sql if Rails.application.config.x.respond_to?(:queries)
      return app_config unless app_config.nil?

      env_value = ENV["QUERIES_LOG_SQL"]
      return cast_boolean(env_value) unless env_value.nil?

      !Rails.env.production?
    rescue StandardError
      true
    end

    def cast_boolean(value)
      %w[1 true yes y on].include?(value.to_s.strip.downcase)
    end

    def safe_logger
      Rails.logger if Rails.respond_to?(:logger)
    end

    def log_sql_execution(sql_text:, started_at:, success:, error: nil)
      return unless sql_logging_enabled?

      logger = safe_logger
      return if logger.nil?

      payload = build_sql_log_payload(sql_text: sql_text, started_at: started_at, success: success, error: error)
      logger.info(payload)
    rescue StandardError
      nil
    end

    def build_sql_log_payload(sql_text:, started_at:, success:, error: nil)
      normalized_sql = normalize_sql(sql_text)
      masked_sql = mask_sensitive_values(normalized_sql)
      truncated_sql, sql_length, sql_truncated = truncate_sql(masked_sql)

      {
        event: "queries.sql_execution",
        query_class: self.class.name,
        sql_source: file_source,
        sql_file: file.to_s,
        timestamp: Time.current.utc.iso8601,
        duration_ms: ((current_monotonic_time - started_at) * 1000).round(2),
        success: success,
        error_class: error&.class&.name,
        sql: truncated_sql,
        sql_length: sql_length,
        sql_truncated: sql_truncated,
        sensitive_filtered: truncated_sql.include?("[FILTERED]")
      }.compact
    end

    def normalize_sql(sql_text)
      sql_text.to_s.gsub(/\s+/, " ").strip
    end

    def truncate_sql(sql_text)
      max_size = 500
      sql_length = sql_text.length
      return [ sql_text, sql_length, false ] if sql_length <= max_size

      [ "#{sql_text[0...max_size]}...", sql_length, true ]
    end

    def sensitive_filters
      configured = Rails.application.config.filter_parameters
      defaults = %w[password token secret api_key access_token refresh_token authorization]
      Array(configured).map(&:to_s) + defaults
    rescue StandardError
      %w[password token secret api_key access_token refresh_token authorization]
    end

    def sensitive_key?(key, filters)
      key_name = key.to_s.downcase
      filters.any? do |filter|
        if filter.is_a?(Regexp)
          key_name.match?(filter)
        else
          key_name.include?(filter.to_s.downcase)
        end
      end
    end

    def mask_sensitive_values(sql_text)
      filters = sensitive_filters

      params.each_with_object(sql_text.dup) do |(key, value), output|
        next unless sensitive_key?(key, filters)
        next if value.nil?

        escaped_value = Regexp.escape(value.to_s)
        output.gsub!(/#{escaped_value}/i, "[FILTERED]")
      end
    end

    def safe_sql_for_logging(executed_sql)
      return executed_sql if executed_sql.present?

      normalize_sql(sql)
    rescue StandardError
      nil
    end

    def normalize_input_params(value)
      self.class.normalize_params_input(value)
    end
  end
end
