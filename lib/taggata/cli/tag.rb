module Taggata
  module Cli
    class TagCommand < Clamp::Command

      option "-s", "SEPARATOR", 'separator used to split input into tokens', :attribute_name => :separator, :default => " "

      parameter 'TAG_QUERY', 'the tag query', :attribute_name => :tag_query, :required => true
      parameter 'SEARCH_QUERY', 'the query to search', :attribute_name => :search_query, :required => true
 
      def execute
        tags = ::Taggata::Parser::Tag.parse(tag_query)
        files = ::Taggata::Parser::Query.parse(search_query, @separator)
        Taggata::Database.transaction do
          tags[:add].each { |tag| tag.add_untagged_files files }
          tags[:del].each do |tag|
            files.each { |file| tag.remove_file file }
          end
        end
      end

    end
  end
end
