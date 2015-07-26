require 'sequel'

require 'taggata'
require 'minitest/autorun'
require 'minitest/reporters'
require 'fileutils'
require 'mocha/mini_test'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
