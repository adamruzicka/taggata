module Taggata
  class Tag < Sequel::Model
    many_to_many :files,
                 :left_id => :tag_id,
                 :right_id => :file_id,
                 :join_table => :file_tags

    set_schema do
      primary_key :id
      String :name
    end

    create_table unless table_exists?

    def self.files(query)
      tag = find(query)
      tag.nil? ? [] : tag.files
    end
  end
end
