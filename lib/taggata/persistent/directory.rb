module Taggata
  module Persistent
    class Directory < Abstract

      include ::Taggata::Persistent::WithParent

      attr_reader :db, :name, :parent_id, :id

      def initialize(db, name, parent_id = nil, id = nil)
        @db = db
        @name = name
        @parent_id = parent_id
        @id = id
      end

      def self.table
        :taggata_directories
      end

      def to_hash
        {
          :name => name,
          :parent_id => parent_id,
          :id => id
        }
      end

      def self.new_from_hash(db, hash)
        self.new(db,
                 hash[:name],
                 hash[:parent_id],
                 hash[:id])
      end

      def show(indent = 0)
        indent.times { print "  " }
        puts "+ #{self.name}"
        entries.each { |e| e.show(indent + 1) }
      end

      def directories
        @child_directories ||= db.find_child_directories(self)
      end

      def files
        @child_files ||= db.find_child_files(self)
      end

      def invalidate_cache
        @child_directories = @child_files = nil
      end

      def entries
        directories + files
      end

      # Scan children of this directory
      def scan
        scanner = ::Taggata::FilesystemScanner.new db
        scanner.process(self)
        validate
      end

      def validate
        missing = ::Taggata::Persistent::Tag.find_or_create(:name => MISSING_TAG_NAME)
        files.reject { |f| ::File.exist? f.path }.each { |f| f.add_tag missing }
        directories.each(&:validate)
      end

      # Get full path of this directory
      #
      # @result full path of this directory
      def path
        parents = [self]
        parents << parents.last.parent while parents.last.parent
        ::File.join(parents.reverse.map(&:name))
      end
    end
  end
end
