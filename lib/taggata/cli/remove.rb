module Taggata
  module Cli
    class RemoveCommand < Clamp::Command

      parameter "QUERY", 'the query to perform', :attribute_name => :query, :required => true
      
      def execute
        parser = ::Taggata::Parser::Query.new @db
        results = parser.parse query
        @db.transaction do
          results.each(&:destroy)
        end
      end

    end
  end
end
