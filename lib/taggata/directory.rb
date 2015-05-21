module Taggata
  class Directory < Sequel::Model(:directories)
    set_schema do
      primary_key :id
      String :name
      foreign_key :parent_id, :directories
    end

    create_table unless table_exists?

    one_to_many :directories,
                :key => :parent_id,
                :class => self

    one_to_many :files,
                :key => :parent_id,
                :class => ::Taggata::File

    many_to_one :parent,
                :key => :parent_id,
                :class => self

    def entries
      directories + files
    end

    # Scan children of this directory
    def scan
      scanner = ::Taggata::FilesystemScanner.new
      scanner.process(self)
      validate
    end

    def validate
      missing = ::Taggata::Tag.find_or_create(:name => MISSING_TAG_NAME)
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
