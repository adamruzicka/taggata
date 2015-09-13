module Taggata
  module Parser
    class Query

      attr_reader :db

      def initialize(db)
        @db = db
      end

      def parse(query, separator = ' ')
        process(postfix(query, separator))
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
          tag = ::Taggata::Persistent::Tag.find_one(db, :name => name)
          tag.nil? ? [] : tag.files
        when 'like'
          files = ::Taggata::Persistent::File.find(db, Sequel.like(:name, name))
        when 'file', 'name'
        #   File.all.select { |f| f.name[/#{name}/] }
          files = ::Taggata::Persistent::File.find(db, {})
          files.select { |f| f.name[/#{name}/] }
        when 'path'
          files = ::Taggata::Persistent::File.find(db, {})
          files.select { |f| f.path[/#{name}/] }
        when 'missing'
          tag = ::Taggata::Persistent::Tag.find_or_create(db, :name => MISSING_TAG_NAME)
          tag.files
        when 'untagged'
          db.find_untagged_files
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
