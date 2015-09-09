require 'taggata_test_helper'

module Taggata
  module Models
    describe Directory do

      it 'can be created as root' do
        root = Directory.find_or_create :name => 'root'
        root.id.must_equal 1
        root.parent.must_be_nil
      end

      it 'can have children' do
        root = Directory.find_or_create :name => 'root'
        subdir = Directory.find_or_create :name => 'subdir', :parent_id => root.id
        subdir.parent_id.must_equal root.id
        file = File.find_or_create :name => 'file', :parent_id => subdir.id
        file.path.must_equal "root/subdir/file"
        subdir.files.length.must_equal 1
        subdir.directories.length.must_equal 0
        root.entries.length.must_equal 1
      end

    end

    describe File do
      let(:root) { Directory.find_or_create :name => 'root' }

      it 'cannot be created without parent' do
        Proc.new { File.find_or_create(:name => 'myfile') }.must_raise Sequel::NotNullConstraintViolation
        File.find_or_create :name => 'myfile', :parent_id => root.id
      end

      it 'can be tagged' do
        file = File.find_or_create :name => 'myfile', :parent_id => root.id
        tag = Tag.find_or_create :name => 'mytag'
        file.add_tag(tag)
        file.tags.map(&:name).must_equal ['mytag']
      end

      it 'can have tags removed' do
        file = File.find_or_create :name => 'myfile', :parent_id => root.id
        tag = Tag.find_or_create :name => 'mytag'
        file.add_tags tag
        file.tags.length.must_equal 1
        file.remove_tags tag
        file.tags.length.must_equal 0
      end

    end
  end
end
