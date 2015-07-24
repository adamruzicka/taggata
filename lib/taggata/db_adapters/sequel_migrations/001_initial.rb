Sequel.migration do
  up do
    create_table(:taggata_directories) do
      primary_key :id
      column :name, String
      foreign_key :parent_id, :taggata_directories, type: Integer
    end

    create_table(:taggata_files) do
      primary_key :id
      column :name, String
      foreign_key :parent_id, :taggata_directories, type: Integer, :null => false
    end

    create_table(:taggata_tags) do
      primary_key :id
      column :name, String, unique: true
    end

    create_table(:taggata_file_tags) do
      foreign_key :file_id, :taggata_files, type: Integer, null: false
      foreign_key :tag_id, :taggata_tags, type: Integer, null: false
      index [:file_id, :tag_id], unique: true
      primary_key [:file_id, :tag_id]
    end
  end

  down do
    drop_table(:taggata_file_tags)
    drop_table(:taggata_tags)
    drop_table(:taggata_files)
    drop_table(:taggata_directories)
  end
end
