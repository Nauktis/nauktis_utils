module NauktisUtils
	# Class to find and handle duplicate files.
  class Duplicate
    include Logging

    def self.algorithm(name)
      key = name.to_sym
      @@algorithms ||= {}
      unless @@algorithms.has_key? key
        @@algorithms[:name] = proc { |file| File.basename(file).downcase }
        @@algorithms[:size] = proc { |file| File.size(file) }
        @@algorithms[:md5] = proc { |file| FileDigester.digest(file, :md5) }
        @@algorithms[:sha1] = proc { |file| FileDigester.digest(file, :sha1) }
        @@algorithms[:sha3] = proc { |file| FileDigester.digest(file, :sha3) }
      end
      @@algorithms.fetch key
    end

    # ========================================
    # Handling Strategies
    # ========================================
    class HandlingStrategy
      class BaseHandlingStrategy
        attr_accessor :deleting_strategy
        def initialize(deleting_strategy)
          @deleting_strategy = deleting_strategy
        end
      end

      class KeepOne < BaseHandlingStrategy
        def handle(files)
          files = files.sort
          file_kept = files.shift
          files.each do |duplicate|
            @deleting_strategy.delete_duplicate(duplicate, file_kept)
          end
        end
      end

      class OriginalFrom < KeepOne
        def initialize(deleting_strategy, directory)
          super(deleting_strategy)
          @directory = File.expand_path(directory)
        end

        def handle(files)
          files = files.sort
          i = files.find_index do |f|
            f.start_with?(@directory)
          end
          unless i.nil?
            file_kept = files.delete_at(i)
            files.each do |duplicate|
              @deleting_strategy.delete_duplicate(duplicate, file_kept)
            end
          end
        end
      end

      class NoDeleteIn < BaseHandlingStrategy
        def initialize(deleting_strategy, directories)
          super(deleting_strategy)
          @directories = directories.map { |d| File.expand_path(d) }
        end

        def handle(files)
          files = files.sort
          files_kept, files_deleted = files.partition do |e|
            @directories.any? {|d| e.start_with?(d) }
          end
          if files_kept.size > 0
            files_deleted.each do |duplicate|
              @deleting_strategy.delete_duplicate(duplicate, files_kept.first)
            end
          end
        end
      end

      class Analyse
        attr_reader :counters
        def initialize
          @counters = Hash.new(0)
        end

        def handle(files)
          @counters[:pairs] += 1
          @counters[:duplicates] += (files.size - 1)
          @counters[:size] += ((files.size - 1) * File.size(files.first))
        end
      end

      class OnlyDeleteIn < BaseHandlingStrategy
      # TODO
      end
    end

    # ========================================
    # Deleting Strategies
    # ========================================
    class DeletingStrategy
      class BaseDeletingStrategy
        include Logging
      end

      class Simulate < BaseDeletingStrategy
        def delete_duplicate(duplicate, original)
          logger.info "#{duplicate} duplicate of #{original}"
        end
      end

      class Simple < BaseDeletingStrategy
        def delete_duplicate(duplicate, original)
          logger.info "Deleting #{duplicate}, duplicate of #{original}"
          File.delete(duplicate)
        end
      end

      class Safe < Simple
        def delete_duplicate(duplicate, original)
          if FileUtils.compare(duplicate, original)
            super
          else
            logger.warn "Duplicate #{duplicate} was a false positive with #{original}"
          end
        end
      end
    end

    # ========================================
    attr_accessor :handling_strategy

    def initialize(handling_strategy)
      @handling_strategy = handling_strategy
    end

    def clean(directories)
      logger.info "Searching duplicates in #{directories}"
      directories.map! { |d| File.expand_path(d) }
      files = files_in(directories)
      logger.info "Number of files: #{files.size.to_s(:delimited)}"
      size_before = size_of(directories)
      logger.info "Total size: #{size_before.to_s(:human_size)}"

      @groupings = [self.class.algorithm(:size), self.class.algorithm(:md5), self.class.algorithm(:sha3)]
      multi_group_by(files, 0)

      size_after = size_of(directories)
      logger.info "Total size: #{size_after.to_s(:human_size)}"
      reduction_ratio = (100 * (size_before - size_after) / size_before.to_f).round(2)
      logger.info "Size reduced by #{reduction_ratio}% (#{size_after.to_s(:delimited)}/#{size_before.to_s(:delimited)})"
    end

    private

    def multi_group_by(files, index)
      if index >= @groupings.size
        handle_duplicates(files)
      else
        files.group_by(&@groupings[index]).values.each do |sub|
          multi_group_by(sub, index + 1) if sub.size > 1
        end
      end
    end

    def handle_duplicates(duplicates)
      # For extra safety we check a file doesn't appear twice.
      unless duplicates.uniq == duplicates
        s = "A file appears twice: #{duplicates}"
        logger.error s
        raise s
      end
      handling_strategy.handle(duplicates)
    end

    # Returns the list of files in the directories provided
    def files_in(directories)
      files = []
      Find.find(*directories) do |path|
        unless File.directory?(path) or File.symlink?(path)
          files << File.expand_path(path)
        end
      end
      files.uniq
    end

    # Returns the total size of the directories provided
    def size_of(directories)
      size = 0
      files_in(directories).each do |f|
        size += File.size(f)
      end
      size
    end
  end
end
