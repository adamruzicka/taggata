module Taggata
  module Parser
    class Tag

      attr_reader :db

      def initialize(db)
        @db = db
      end

      # Parses give tagging string
      #
      # @param query String tagging string
      # @return [Hash]
      def parse(query)
        result = { :add => [], :del => [] }
        hash = query.split.reduce(result) do |acc, tag|
          handle_tag(tag, acc)
        end
        dels = hash[:del].empty? ? [] : ::Taggata::Persistent::Tag.find(db, :name => hash[:del])
        adds = hash[:add].empty? ? [] : find_tags(hash[:add])
        { :add => adds, :del => dels }
      end

      private

      def find_tags(names)
        in_db = ::Taggata::Persistent::Tag.find(db, :name => names).map(&:name)
        values = (names - in_db).map { |name| { :name => name } }
        ::Taggata::Persistent::Tag.bulk_insert(db, values)
        ::Taggata::Persistent::Tag.find(db, :name => names)
      end

      def handle_tag(tag, result)
        if tag.start_with?('-')
          result[:del] << tag[1..-1]
        elsif tag.start_with?('+')
          result[:add] << tag[1..-1]
        else
          fail "Unknown tag specifier '#{tag}'"
        end
        result
      end
    end
  end
end
