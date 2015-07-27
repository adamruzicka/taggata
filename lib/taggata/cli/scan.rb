module Taggata
  module Cli
    class ScanCommand < Clamp::Command

      parameter "[ROOT]", "the root of the scanned tree", :attribute_name => :root_path, :default => './'

      def execute
        scanner = Taggata::Scanner.new @db
        root = Taggata::Persistent::Directory.find_or_create @db, :name => root_path
        scanner.process(root)
      end

    end
  end
end
