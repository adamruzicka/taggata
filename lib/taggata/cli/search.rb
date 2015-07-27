module Taggata
  module Cli
    class SearchCommand < Clamp::Command

      option "-c", :flag, 'show only matched count',       :attribute_name => :count, :default => false
      option "-n", :flag, 'show only names without paths', :attribute_name => :names, :default => false

      parameter "QUERY",  'the query to perform',          :attribute_name => :query, :required => true
 
      def execute
        results = ::Taggata::Parser::Query.new(@db).parse(query)
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
  end
end
