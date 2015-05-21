module Taggata
  class File < Sequel::Model(:files)
    set_schema do
      primary_key :id
      String :name
      foreign_key :parent_id, :directories
    end

    create_table unless table_exists?

    require 'taggata/directory'

    many_to_one :parent,
                :key => :parent_id,
                :class => ::Taggata::Directory

    many_to_many :tags,
                 :left_id => :file_id,
                 :right_id => :tag_id,
                 :join_table => :file_tags

    # Gets full path of the file
    #
    # @return String full path of the file
    def path
      ::File.join(parent.path, name)
    end
  end
end
