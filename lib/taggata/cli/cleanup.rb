module Taggata
  module Cli
    class CleanupCommand < Clamp::Command

      option %w(-t --tags),    :flag, 'remove unused tags', :default => true, :attribute_name => :tags

      def execute
        remove_tags if tags?
      end

      private

      def remove_tags
        tags = @db.find_tags_without_files
        count = @db.destroy(Taggata::Persistent::Tag, tags.map(&:to_hash)) unless tags.empty?
        puts "Removed tags: #{format_count count}" unless @quiet
      end

      def format_count(count)
        count.nil? ? 0 : count
      end

    end
  end
end
