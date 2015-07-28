module Taggata
  module Cli
    class CleanupCommand < Clamp::Command

      option %w(-t --tags), :flag, 'remove unused tags', :default => true, :attribute_name => :tags

      def execute
        Taggata::Database.transaction do
          remove_tags if tags?
        end
      end

      private

      def remove_tags
        ids = Models::Tag.unused_tag_ids
        count = Models::Tag.where(:id => ids).delete
        puts "Removed tags: #{format_count count}" unless @quiet
      end

      def format_count(count)
        count.nil? ? 0 : count
      end

    end
  end
end
