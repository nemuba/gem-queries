require "rails/generators"

module Queries
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_template_file
        template "application_query.rb", "app/queries/application_query.rb"
      end
    end
  end
end
