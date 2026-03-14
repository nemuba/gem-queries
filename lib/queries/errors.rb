module Queries
  module Errors
    class SqlFileNotFoundError < RuntimeError; end
    class MissingRequiredParamsError < RuntimeError; end
  end
end
