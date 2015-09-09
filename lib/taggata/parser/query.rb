module Taggata
  module Parser
    class Query
      class << self

        def parse(query, separator = " ")
          ids = process(postfix(query, separator))
          Models::File.where(:id => ids).all
        end

        private

        # Resolves a terminal to a value
        #
        # @param token String the terminal token to resolve
        # @result [::Taggata::File] list of files with this tag
        def resolve(token)
          type, name = token.split(':', 2)
          case type.downcase
          when 'is', 'tag'
            tag = Models::Tag.find(:name => name)
            tag.nil? ? [] : tag.files_dataset.map(:id)
          when 'like'
            Models::File.where(Sequel.like(:name, name)).map(:id)
          when 'file', 'name'
            files = Models::File.all
            files.select { |f| f.name[/#{name}/] }.map(&:id)
          when 'path'
            files = Models::File.all.select { |f| f.path[/#{name}/] }.map(&:id)
          when 'missing'
            Models::Tag.find_or_create(:name => MISSING_TAG_NAME).files_dataset.map(:id)
          when 'untagged'
            tagged_file_ids = Models::Tag.map(&:files).flatten.map(&:id)
            Models::File.exclude(:id => tagged_file_ids).map(:id)
          else
            fail "Unknown token type '#{type}'"
          end
        end

        # Evaluates the input
        #
        # @param postfix [String] the input in postfix notation as array
        # @return [::Taggata::File]
        def process(postfix)
          stack = []
          postfix.each do |token|
            if operator? token
              op_b = stack.pop
              op_a = stack.pop
              stack << apply(token, op_a, op_b)
            else
              stack << resolve(token)
            end
          end
          stack.last
        end

        # Applies operator to operands op_A and op_B
        #
        # @param operator Symbol the operation(:and, :or) to apply to operands
        # @param op_A [::Taggata::File] first operand
        # @param op_B [::Taggata::File] second operand
        # @result [::Taggata::File] result of applying operator to operands
        def apply(operator, op_A, op_B)
          case operator
          when :and
            op_A & op_B
          when :or
            op_A | op_B
          else
            fail "Unknown operator '#{operator}'"
          end
        end

        # Converts string to postfix notation
        #
        # @param query String the query string
        # @result [String] query in postfix notation as an array
        def postfix(query, separator = ' ')
          postfix = []
          operators = []
          query.split(separator).each do |token|
            if operator? token
              operators << translate(token)
            elsif token == ')'
              loop do
                current = operators.pop
                current == '(' ? break : postfix << current
              end
            else
              postfix << token
            end
          end
          operators.each { |op| postfix << op }
          postfix
        end

        # Translates token to symbol or leaves it alone
        #
        # @param token String
        # @result the token
        def translate(token)
          return :and if ['and', '&'].include? token.downcase
          return :or if ['or', '|'].include? token.downcase
          token
        end

        # Checks if token is an operator
        #
        # @param token String
        # @result true/false
        def operator?(token)
          ['&', '|', 'or', 'and', '(', :and, :or].include? token.downcase
        end
      end
    end
  end
end
