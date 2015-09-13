module Taggata
  module Cli
    class SearchCommand < Clamp::Command

      option "-c", :flag, 'show only matched count',       :attribute_name => :count, :default => false
      option "-n", :flag, 'show only names without paths', :attribute_name => :names, :default => false
      option '-s', 'SEPARATOR', 'separator to use for splitting into tokens', :attribute_name => :separator, :default => ' '
      option '-0', :flag, 'print result as a list of NULL-terminated items', :attribute_name => :null_terminated, :default => false

      parameter "QUERY",  'the query to perform',          :attribute_name => :query, :required => true
 
      def execute
        results = ::Taggata::Parser::Query.new(@db).parse(query, @separator)
        if count?
          puts results.count
        else
          if results.empty?
            puts "No results matching the query." unless @null_terminated
          else
            method = names? ? :name : :path
            results.each { |file| print "#{file.send(method)}#{@null_terminated ? "\x00" : "\n"}" }
          end
        end
      end

    end
  end
end
