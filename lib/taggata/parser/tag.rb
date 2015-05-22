module Taggata
  module Parser
    class Tag
      # Parses give tagging string
      #
      # @param query String tagging string
      # @return [Hash]
      def self.parse(query)
        result = { :add => [], :del => [] }
        hash = query.split.reduce(result) do |acc, tag|
          handle_tag(tag, acc)
        end
        dels = hash[:del].empty? ? [] : ::Taggata::Tag.where(:name => hash[:del]).all
        adds = hash[:add].empty? ? [] : find_tags(hash[:add])
        { :add => adds, :del => dels }
      end

      private

      def self.find_tags(names)
        in_db = ::Taggata::Tag.where(:name => names).all
        ::Taggata::Tag
          .dataset
          .multi_insert((names - in_db).map { |name| { :name => name } })
        ::Taggata::Tag.where(:name => names).all
      end

      def self.handle_tag(tag, result)
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
