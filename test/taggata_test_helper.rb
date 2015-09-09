require 'sequel'
require 'taggata/database'
Taggata::Database.initialize(:sqlite, nil)
require 'taggata'
require 'minitest/autorun'
require 'minitest/reporters'
require 'fileutils'
require 'mocha/mini_test'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class Minitest::Spec
  
  before do
    Taggata::Database.reset
    # Taggata::Database.transaction do
    #   Taggata::Models::Tag.all.each(&:remove_all_files)
    #   Taggata::Models::File.all.each(&:remove_all_tags)
    #   Taggata::Models::Tag.select.destroy
    #   Taggata::Models::File.select.destroy
    #   # require 'pry'; binding.pry
    #   Taggata::Models::Directory.order_by(:parent_id).reverse.destroy
    # end
  end

end