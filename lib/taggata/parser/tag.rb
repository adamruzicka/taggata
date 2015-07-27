module Taggata
  module Parser
    class Tag
      class << self

        # Parses give tagging string
        #
        # @param query String tagging string
        # @return [Hash]
        def parse(query)
          result = { :add => [], :del => [] }
          hash = query.split.reduce(result) do |acc, tag|
            handle_tag(tag, acc)
          end
          dels = hash[:del].empty? ? [] : Models::Tag.where(:name => hash[:del]).all
          adds = hash[:add].empty? ? [] : find_tags(hash[:add])
          { :add => adds, :del => dels }
        end

        private

        def find_tags(names)
          Models::Tag.db.transaction do
            names.map { |name| Models::Tag.find_or_create(:name => name) }
          end
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
end
