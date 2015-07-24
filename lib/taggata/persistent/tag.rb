module Taggata
  module Persistent
    class Tag < Abstract

      attr_reader :db, :name, :id

      def initialize(db, name, id = nil)
        @db = db
        @name = name
        @id = id
      end

      def files
        file_tags.map { |file_tag| file_tag.file }
      end

      def file_tags
        FileTag.find(db, :tag_id => id)
      end

      def to_hash
        {
          :name => name,
          :id => id
        }
      end

      def self.new_from_hash(db, hash)
        self.new(db,
                 hash[:name],
                 hash[:id])
      end

      def self.table
        :taggata_tags
      end

    end
  end
end
