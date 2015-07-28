module Taggata
  module Models

    class Tag < Sequel::Model(:taggata_tags)

      def add_untagged_files(to_add)
        Models::File.where(:id => to_add.map(&:id))
                    .exclude(:id => files.map(&:id))
                    .each { |file| add_file file }
      end

      def self.unused_tag_ids
        ids = Models::Tag.reduce({}) { |acc, tag| acc.merge(tag.id => tag.files.count) }
                         .select { |id, count| count == 0 }
                         .map { |id, count| id }
      end

    end

  end
end
