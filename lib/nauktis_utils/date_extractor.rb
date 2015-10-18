module NauktisUtils
	class DateExtractor
		attr_reader :counters
    DATETIME_FORMAT = "%Y-%m-%d_%H-%M-%S_"
    DATETIME_REGEX = /^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/

    def initialize
      @counters = Hash.new(0)
    end

    def extract_datetime(file_path)
      meta = exiftool(FileBrowser.ensure_valid_file(file_path))
      ['DateTimeOriginal', 'MediaCreateDate'].each do |tag|
        return DateTime.parse(meta[tag]) if meta[tag]
      end
      Tracer.warn "Could not extract date from #{file_path}"
      nil
    end

    def rename(file_path)
      file_path = FileBrowser.ensure_valid_file(file_path)
      @counters[:total] += 1
      unless File.basename(file_path) =~ DATETIME_REGEX
        prepend_date(file_path)
      end
    end

    private

    def prepend_date(file_path)
      datetime = extract_datetime(file_path)
      unless datetime.nil?
        prefix = datetime.strftime(DATETIME_FORMAT)
        current_name = File.basename(file_path)
        unless current_name.start_with?(prefix)
          prefixed_name = File.join(File.dirname(file_path), prefix + current_name)
          if File.exist?(prefixed_name)
            Tracer.warn "Cannot rename #{current_name}, #{prefixed_name} already exists."
          else
            File.rename(file_path, prefixed_name)
            Tracer.info "Renamed #{current_name} to #{File.basename(prefixed_name)}."
          end
        end
      end
    end

    def exiftool(file_path)
      raise "File #{file_path} does not exist" unless File.exist?(file_path)
      result = %x(exiftool -u -d "%Y-%m-%d %H:%M:%S" -json "#{file_path}")
      JSON.parse(result)[0]
    end
	end
end
