$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'nauktis_utils'

def create_file_with_content(directory, content)
  FileUtils.mkpath(directory)
  basename = content.gsub(/\W+/, '')[0..20]
  basename = "unknown" unless basename.size > 0
  file = File.join(directory, basename)
  i = 1
  while File.exists?(file)
    file = File.join(directory, "#{basename}_#{i}")
    i += 1
  end
  File.open(file, 'w') {|f| f.write(content) }
  file
end
