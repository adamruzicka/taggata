module Taggata
  module Cli
    class RemoveCommand < Clamp::Command

      parameter "QUERY", 'the query to perform', :attribute_name => :query, :required => true
      
      def execute
        results = ::Taggata::Parser::Query.parse query
        Models::File.db.transaction do
          results.each(&:destroy)
        end
      end

    end
  end
end
