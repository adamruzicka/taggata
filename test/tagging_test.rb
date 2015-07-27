# require 'taggata_test_helper'

# module Taggata
#   module Persistent
#     describe Directory do
#       let(:db) { Db.new 'sqlite:/', DbAdapters::Sequel }

#       it 'can be created as root' do
#         root = Directory.find_or_create db, :name => 'root'
#         root.id.must_equal 1
#         root.parent.must_be_nil
#       end

#       it 'can have children' do
#         root = Directory.find_or_create db, :name => 'root'
#         subdir = Directory.find_or_create db, :name => 'subdir', :parent_id => root.id
#         subdir.parent_id.must_equal root.id
#         file = File.find_or_create db, :name => 'file', :parent_id => subdir.id
#         file.path.must_equal "root/subdir/file"
#         subdir.files.length.must_equal 1
#         subdir.directories.length.must_equal 0
#         root.entries.length.must_equal 1
#       end

#     end

#     describe File do
#       let(:db) { Db.new 'sqlite:/', DbAdapters::Sequel }
#       let(:root) { Directory.find_or_create db, :name => 'root' }

#       it 'cannot be created without parent' do
#         Proc.new { File.find_or_create(db, :name => 'myfile') }.must_raise Sequel::NotNullConstraintViolation
#         File.find_or_create db, :name => 'myfile', :parent_id => root.id
#       end

#       it 'can be tagged' do
#         file = File.find_or_create db, :name => 'myfile', :parent_id => root.id
#         tag = Tag.find_or_create db, :name => 'mytag'
#         file.add_tags(tag)
#         file.tags.map(&:name).must_equal ['mytag']
#         file.add_tags_by_name('tag1', 'tag2', 'tag3')
#         file.tags.map(&:name).must_equal ['mytag', 'tag1', 'tag2', 'tag3']
#       end

#       it 'can have tags removed' do
#         file = File.find_or_create db, :name => 'myfile', :parent_id => root.id
#         tag = Tag.find_or_create db, :name => 'mytag'
#         file.add_tags tag
#         file.add_tags_by_name 'mytag2'
#         file.tags.length.must_equal 2
#         file.remove_tags tag
#         file.remove_tags_by_name 'mytag2'
#         file.tags.length.must_equal 0
#       end

#     end
#   end
# end
