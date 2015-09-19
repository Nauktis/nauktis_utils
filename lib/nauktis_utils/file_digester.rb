require 'openssl'
require 'sha3'

module NauktisUtils
	module FileDigester
    ALGORITHMS = [:md5, :sha1, :sha256, :sha512, :sha3]

    # Returns the hexdigest of the file provided.
    def self.digest(filename, algorithm = :sha1)
      full_path = FileBrowser.ensure_valid_file(filename)
      raise "Unknown algorithm #{algorithm}, use #{ALGORITHMS}" unless ALGORITHMS.include?(algorithm.to_sym)
      if algorithm.to_sym == :sha3
        SHA3::Digest.file(full_path).hexdigest
      else
        OpenSSL::Digest.new(algorithm.to_s).file(full_path).hexdigest
      end
    end

    # Generates a file next to the file provided containing its digest
    def self.generate_digest_file(filename, algorithm = :sha1)
      digest = self.digest(filename, algorithm)
      File.write("#{File.expand_path(filename)}.#{algorithm}", digest)
    end

    # Checks the digest files next to the file provided.
    # Returns true if all the digest files contain proper digest
    def self.digest_file_valid?(filename)
      full_path = FileBrowser.ensure_valid_file(filename)
      valid = true
      ALGORITHMS.each do |algorithm|
        digest_file = "#{full_path}.#{algorithm}"
        if FileBrowser.valid_file?(digest_file)
          unless self.digest(filename, algorithm) == File.read(digest_file)
            valid = false
            break
          end
        end
      end
      valid
    end
  end
end
