module Taggata
  module Persistent
    class File < Abstract

      include WithParent

      attr_reader :db, :name, :parent_id, :id

      def initialize(db, name, parent_id, id = nil)
        @name = name
        @db = db
        @parent_id = parent_id
        @id = id
      end

      def add_tags_by_name(*tag_names)
        tag_records = nil
        db.transaction do
          tag_records = tag_names.map { |tag_name| ::Taggata::Persistent::Tag.find_or_create(db, :name => tag_name) }
        end
        add_tags(*tag_records)
      end

      def add_tags(*to_add)
        current_tag_ids = tags.map(&:id)
        missing_tag_ids = to_add.map(&:id) - current_tag_ids
        return if missing_tag_ids.empty?
        options = missing_tag_ids.map { |tag_id| { :file_id => id, :tag_id => tag_id } }
        db.bulk_insert(FileTag, options)
      end

      def remove_tags(*to_remove)
        return if to_remove.empty?
        current_tag_ids = tags.map(&:id)
        to_remove_ids = current_tag_ids - to_remove.map(&:id)
        options = to_remove_ids.map { |tag_id| { :file_id => id, :tag_id => tag_id } }
        db.destroy(FileTag, options)
      end

      def remove_tags_by_name(*tag_names)
        tags = tag_names.map { |tag_name| Tag.find_or_create db, :name => tag_name }
        remove_tags(*tags)
      end

      def destroy
        file_tags.each(&:destroy)
        super
      end

      def file_tags
        ::Taggata::Persistent::FileTag.find(db, :file_id => id)
      end

      def tags
        file_tags.map(&:tag)
      end

      def to_hash
        {
          :name => name,
          :id => id,
          :parent_id => parent_id
        }
      end

      def self.new_from_hash(db, hash)
        self.new(db,
                 hash[:name],
                 hash[:parent_id],
                 hash[:id])
      end

      def self.table
        :taggata_files
      end

      def show(indent = 0)
        indent.times { print "  " }
        puts "- #{self.name}"
      end

      def path
        ::File.join(parent.path, name)
      end

    end
  end
end

#     def before_destroy
#       remove_all_tags
#     end
#
#     # Gets full path of the file
#     #
#     # @return String full path of the file

#   end
# end
