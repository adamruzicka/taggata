require 'clamp'
require 'taggata'

module Taggata
  module Cli
    Clamp do

      option "--db-path", "DB_PATH", "path to the DB", :attribute_name => :db, :required => true do |db_path|
        Taggata::Db.new "sqlite://#{db_path}", Taggata::DbAdapters::Sequel
      end
      option ['-v', '--verbose'], :flag, 'be verbose', :default => false
      option ['-q', '--quiet'], :flag, 'be quite', :default => false

      subcommand "scan", "Scan the system" do

        parameter "[ROOT]", "the root of the scanned tree", :attribute_name => :root_path, :default => './'

        def execute
          scanner = Taggata::Scanner.new db
          root = Taggata::Persistent::Directory.find_or_create db, :name => root_path
          scanner.process(root)
        end

      end

      subcommand 'tag', 'tag a file matching query' do

        parameter 'TAG_QUERY', 'the tag query', :attribute_name => :tag_query, :required => true
        parameter 'SEARCH_QUERY', 'the query to search', :attribute_name => :search_query, :required => true

        def execute
          tags = ::Taggata::Parser::Tag.new(db).parse(tag_query)
          files = ::Taggata::Parser::Query.new(db).parse(search_query)
          db.transaction do
            files.each do |file|
              file.add_tags *tags[:add]
              file.remove_tags *tags[:del]
            end
          end
        end

      end

      subcommand 'search', "search the database" do

        option "-c", :flag, 'show only matched count', :attribute_name => :count, :default => false
        option "-n", :flag, 'show only names without paths', :attribute_name => :names, :default => false
        parameter "QUERY", 'the query to perform', :attribute_name => :query, :required => true

        def execute
          results = ::Taggata::Parser::Query.new(db).parse(query)
          if count?
            puts results.count
          else
            if results.empty?
              puts "No results matching the query."
            else
              method = names? ? :name : :path
              results.each { |file| puts file.send(method) }
            end
          end
        end

      end

      subcommand 'remove', 'remove files matching query' do

        parameter "QUERY", 'the query to perform', :attribute_name => :query, :required => true

        def execute
          parser = ::Taggata::Parser::Query.new db
          results = parser.parse query
          db.transaction do
            results.each(&:destroy)
          end
        end

      end

      subcommand 'list', 'list things in database' do

        parameter 'TYPE', 'type of records to list, can be one of file, directory, tag', :attribute_name => :type, :required => true do |type|
          signal_usage_error 'TYPE must be one of file, directory, tag' unless %(file directory tag).include? type
          type.to_sym
        end

        def execute
          case type
          when :file
            db.find(Taggata::Persistent::File, {}).each { |file| puts file.path }
          when :directory
            db.find(Taggata::Persistent::Directory, {}).each { |dir| puts dir.path }
          when :tag
            db.find(Taggata::Persistent::Tag, {}).each { |tag| puts tag.name }
          end
        end

      end

    end
  end
end
