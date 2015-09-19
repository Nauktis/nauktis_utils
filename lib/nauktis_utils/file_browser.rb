module NauktisUtils
  # Provide some utility methods for file handling.
  module FileBrowser
    # Returns true if the file provided is a valid (i.e. existing) file.
    def self.valid_file?(filename)
      full_path = File.expand_path(filename)
      File.exist?(full_path) and not File.directory?(full_path)
    end

    # Returns true if the file provided is a valid (i.e. existing) directory.
    def self.valid_directory?(directory)
      full_path = File.expand_path(directory)
      File.exist?(full_path) and File.directory?(full_path)
    end

    # Raises an exception if the path provided is not an existing file.
    # Returns the expanded path of the file
    def self.ensure_valid_file(filename)
      raise "#{filename} is not a valid file." unless self.valid_file?(filename)
      File.expand_path(filename)
    end

    # Raises an exception if the path provided is not an existing directory.
    # Returns the expanded path of the directory
    def self.ensure_valid_directory(directory)
      raise "#{directory} is not a valid directory." unless self.valid_directory?(directory)
      File.expand_path(directory)
    end

    # Returns true if the string provided contains characters that will be interpreted in a glob operation.
    def self.contains_glob_character?(path)
      full_path = File.expand_path(path)
      ['*', '?', '[', '{'].each do |s|
        return true if full_path.include?(s)
      end
      return false
    end

    # Recursively goes through all the files contained in a directory.
    def self.each_file(directory)
      raise "Can't use glob on #{directory_path}, dangerous character #{s}" if contains_glob_character?(directory)
      Dir.glob(File.join(File.expand_path(directory), '**', '*'), File::FNM_DOTMATCH).each do |entry|
        next if File.directory?(entry)
        yield(File.expand_path(entry))
      end
    end

    # Copy a file to destination appending a number if the file already exists at destination.
    def self.copy_file(file, destination_folder)
      destination_folder = self.ensure_valid_directory(destination_folder)
      file_path = self.ensure_valid_file(file)

      file_ext = File.extname(file_path)
      file_basename = File.basename(file_path)
      file_base = File.basename(file_path, file_ext)
      final_file = File.join(destination_folder, file_basename)
      i = 0
      while File.exist?(final_file) do
        i += 1
        final_file = File.join(destination_folder, "#{file_base}#{i}#{file_ext}")
      end
      FileUtils.cp(file_path, final_file)
    end

    # Deletes all the .DS_Store
    def self.delete_ds_store(directory)
      %x(find #{File.expand_path(directory)} -name \.DS_Store -exec rm {} \;)
    end

    # Recursively remove all empty directories
    def self.delete_empty_directories(directory)
      %x(find #{File.expand_path(directory)} -type d -empty -delete)
    end

    # Only keeps alpha numeric characters in a String. Also replaces spaces by underscores.
    def self.sanitize_name(name)
      sanitized = name.strip
      sanitized.gsub!(/[^\w\s\-\.]+/, '')
      sanitized.gsub!(/[[:space:]]+/, '_')
      sanitized
    end

    def self.sanitize_filename(filename)
      name = File.basename(filename, File.extname(filename))
      name = self.sanitize_name(name)
      dirname = File.dirname(filename)
      if dirname != '.'
        File.join(dirname, "#{name}#{File.extname(filename).downcase}")
      else
        "#{name}#{File.extname(filename).downcase}"
      end
    end
  end
end
