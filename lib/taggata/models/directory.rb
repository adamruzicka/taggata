module Taggata
  module Models

    class Directory < Sequel::Model(:taggata_directories)

      def path
        parents = [self]
        while parents.last.parent
          parents << parents.last.parent
        end
        ::File.join(parents.reverse.map(&:name))
      end

      def entries
        @entries ||= directories + files
      end

    end

  end
end