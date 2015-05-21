module Taggata
  module Parser
    class Tag
      # Parses give tagging string
      #
      # @param query String tagging string
      # @return [Hash]
      def self.parse(query)
        result = { :add => [], :del => [] }
        query.split.reduce(result) do |acc, tag|
          handle_tag(tag, acc)
        end
      end

      private

      def self.handle_tag(tag, result)
        if tag.start_with?('-')
          t = ::Taggata::Tag.find(:name => tag[1..-1])
          result[:del] << t unless t.nil?
        elsif tag.start_with?('+')
          result[:add] << ::Taggata::Tag.find_or_create(:name => tag[1..-1])
        else
          fail "Unknown tag specifier '#{tag}'"
        end
        result
      end
    end
  end
end
