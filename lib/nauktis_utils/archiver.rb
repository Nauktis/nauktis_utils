module NauktisUtils
	# Wrapper around TAR
	class Archiver
		include Logging

		def initialize(&block)
			@options = {
				paths: [],
			}
			if block_given?
				instance_eval(&block)
				tar
			end
		end

		def tar
			Tracer.info "Creating archive for #{@options[:paths]}"
			raise "TAR is not available" unless command_available?('tar')
			raise "Only one file archiving is supported for now" unless @options[:paths].size == 1
			source_path = File.expand_path(@options[:paths].first)
			raise "#{source_path} doesn't exist" unless File.exist?(source_path)

			destination_path = FileBrowser.ensure_valid_directory(@options[:destination])
			@options[:name] = "#{Time.now.strftime('%Y-%m-%d')}_#{File.basename(source_path)}" if @options[:name].nil?
			@options[:tar_file] = File.join(destination_path, "#{@options[:name]}#{extension}")
			r = nil
			Dir.chdir(File.dirname(source_path)) do
				r = execute_command("tar #{tar_options.join(' ')} -cf \"#{@options[:tar_file]}\" \"#{File.basename(source_path)}\"")
			end
			raise "TAR returned an error" unless r
			raise "TAR was not created" unless File.exist?(@options[:tar_file])
			Tracer.debug "#{@options[:tar_file]} created"

			# Check the tar structure.
			if @options[:check_structure] or @options[:paranoid]
				Tracer.debug "Checking TAR structure"
				r = execute_command("tar #{tar_options.join(' ')} -tf \"#{@options[:tar_file]}\" >/dev/null")
				raise "TAR structure is not correct" unless r
			end

			if @options[:paranoid]
				Tracer.debug "Checking TAR content"
				Dir.mktmpdir do |dir|
					temp_dir = File.expand_path(dir)
					Dir.chdir(temp_dir) do
						r = execute_command("tar #{tar_options.join(' ')} -xf \"#{@options[:tar_file]}\"")
					end
					raise "Error while untaring the archive" unless r
					r = compare(source_path, File.join(temp_dir, File.basename(source_path)))
					raise "Content doesn't match" unless r
				end
			end

			if @options[:generate_hash]
				Utils::FileDigester.generate_digest_file(@options[:tar_file])
			end
		end

		def add(filename)
			@options[:paths] << File.expand_path(filename)
		end

		# Sets the name of the archive.
		def name(filename)
			@options[:name] = filename
		end

		# Sets the destination folder for the archive.
		def destination(filename)
			@options[:destination] = filename
		end

		def gzip
			@options[:compression] = :gzip
		end

		def bzip2
			@options[:compression] = :bzip2
		end

		def verbose
			@options[:verbose] = true
		end

		def clever_exclude
    	# Exclude .DS_Store & .dropbox
  	end

  	def generate_hash
	  	@options[:generate_hash] = true
	  end

		# Untar the archive after creation to make sure everything is there.
	  def paranoid
	  	@options[:paranoid] = true
	  end

	  # Checks the tar structure after creating the archive.
	  def check_structure
	  	@options[:check_structure] = true
	  end

	  private

	  def command_available?(cmd)
	  	system("which #{cmd} >/dev/null")
	  end

	  def tar_options
	  	s = []
	  	s << '-v' if @options[:verbose]
	  	s << '-z' if @options[:compression] == :gzip
	  	s << '-j' if @options[:compression] == :bzip2
	  	s
	  end

	  def extension
	  	s = '.tar'
	  	s += '.gz' if @options[:compression] == :gzip
	  	s += '.bz2' if @options[:compression] == :bzip2
	  	s
	  end

	  def execute_command(cmd)
	  	Tracer.debug("Executing: #{cmd}")
	  	Kernel.system(cmd)
	  end

	  def compare(original, copy)
	  	a = File.expand_path(original)
	  	b = File.expand_path(copy)
	  	raise "Original file #{original} doesn't exist" unless File.exist?(a)
	  	if File.directory?(a)
	  		Dir.chdir(a) do
	  			Dir.glob('**/*', File::FNM_DOTMATCH) do |f|
	  				if File.exist?(f) and not File.directory?(f)
	  					a_file = File.expand_path(File.join(a, f))
	  					b_file = File.expand_path(File.join(b, f))
	  					logger.debug("Comparing: #{a_file}, #{b_file}")
	  					return false unless File.exist?(b_file) and not File.directory?(b_file)
	  					return false unless Utils::FileDigester.digest(a_file) == Utils::FileDigester.digest(b_file)
	  				end
	  			end
	  		end
	  	else
	  		return false unless File.exist?(b) and not File.directory?(b)
	  		return false unless Utils::FileDigester.digest(a) == Utils::FileDigester.digest(b)
	  	end
	  	return true
	  end
	end
end
