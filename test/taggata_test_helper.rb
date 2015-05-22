require 'sequel'
DB = Sequel.sqlite
DB.create_table :file_tags do
  foreign_key :tag_id, :tags
  foreign_key :file_id, :files
end unless DB.table_exists? :file_tags
Sequel::Model.plugin(:schema)
require 'taggata'
require 'minitest/autorun'
require 'minitest/reporters'
require 'fileutils'
require 'mocha/mini_test'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
