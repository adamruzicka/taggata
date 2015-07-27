module Taggata
  module Cli
    class TagCommand < Clamp::Command

      parameter 'TAG_QUERY', 'the tag query', :attribute_name => :tag_query, :required => true
      parameter 'SEARCH_QUERY', 'the query to search', :attribute_name => :search_query, :required => true
 
      def execute
        tags = ::Taggata::Parser::Tag.new(@db).parse(tag_query)
        files = ::Taggata::Parser::Query.new(@db).parse(search_query)
        @db.transaction do
          files.each do |file|
            file.add_tags *tags[:add]
            file.remove_tags *tags[:del]
          end
        end
      end

    end
  end
end
