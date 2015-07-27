module Taggata
  module Models

    class File
      many_to_many :tags,
                   :join_table => :taggata_file_tags

      many_to_one  :parent,
                   :table => :taggata_directories,
                   :key => :parent_id,
                   :class => Taggata::Models::Directory
    end

    class Directory
      many_to_one :parent,
                  :class => self

      one_to_many :files,
                  :key => :parent_id,
                  :table => :taggata_files
                  
      one_to_many :directories,
                  :key => :parent_id,
                  :class => self
    end

    class Tag
      many_to_many :files,
                   :join_table => :taggata_file_tags
    end

  end
end