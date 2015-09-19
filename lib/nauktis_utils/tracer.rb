module NauktisUtils
	class Tracer
		include Logging

    def self.debug(message)
      log(Logger::DEBUG, message)
    end
    
    def self.info(message)
      log(Logger::INFO, message)
    end
    
    def self.warn(message)
      log(Logger::WARN, message)
    end
    
    def self.error(message)
      log(Logger::ERROR, message)
    end
    
    def self.fatal(message)
      log(Logger::FATAL, message)
    end

		def self.log(severity, message)
      logger.add(severity, message, caller[1])
    end
	end
end
