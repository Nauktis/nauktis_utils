require 'logger'

module NauktisUtils
  # Logger module that can be included in classes
  module Logging
    # Method making the logger mixed where needed
    def logger
      Logging.logger
    end

    # Global, memoized, lazy initialized instance of a logger
    def self.logger
      @logger ||= Logger.new(STDOUT)
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end
  end
end
