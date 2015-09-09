module Taggata
  module Cli
    class SearchCommand < Clamp::Command

      option "-c", :flag, 'show only matched count',       :attribute_name => :count, :default => false
      option "-n", :flag, 'show only names without paths', :attribute_name => :names, :default => false
      option "-0", :flag, 'print output as with NUL-terminated', :attribute_name => :nul_terminated, :default => false
      option "-s", "SEPARATOR", 'separator used to split input into tokens', :attribute_name => :separator, :default => " "

      parameter "QUERY",  'the query to perform',          :attribute_name => :query, :required => true
 
      def execute
        results = ::Taggata::Parser::Query.parse(query, @separator)
        if count?
          puts results.count
        else
          if results.empty?
            puts "No results matching the query." unless @nul_terminated
          else
            method = names? ? :name : :path
            results.each { |file| print_output file.send(method) }
          end
        end
      end

      private

      def print_output(text)
        terminator = @nul_terminated ? "\x00" : "\n"
        print text, terminator
      end
    end
  end
end
