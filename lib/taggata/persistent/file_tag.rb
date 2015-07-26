module Taggata
  module Persistent
    class FileTag < Abstract

      attr_reader :db, :file_id, :tag_id

      def initialize(db, file_id, tag_id)
        @file_id = file_id
        @tag_id = tag_id
        @db = db
      end

      def self.table
        :taggata_file_tags
      end

      def file
        ::Taggata::Persistent::File.find_one(db, :id => file_id)
      end

      def tag
        ::Taggata::Persistent::Tag.find_one(db, :id => tag_id)
      end

      def to_hash
        {
          :file_id => file_id,
          :tag_id => tag_id
        }
      end

      def self.new_from_hash(db, hash)
        self.new(db,
                 hash[:file_id],
                 hash[:tag_id])
      end

      private

      def self.file_tags_hashes(tags, files)
        file_tags = tags.map do |tag|
          files.map { |file| { :file_id => file.id, :tag_id => tag.id } }
        end.flatten
      end

    end
  end
end
