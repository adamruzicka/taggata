module Taggata
  module Cli
    class ScanCommand < Clamp::Command

      parameter "[ROOT]", "the root of the scanned tree", :attribute_name => :root_path, :default => './'

      def execute
        scanner = Scanner.new
        root = Models::Directory.find_or_create :name => root_path, :parent_id => nil
        scanner.process(root)
      end

    end
  end
end
