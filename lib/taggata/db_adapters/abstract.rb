module Taggata
  module DbAdapters
    class Abstract

      attr_reader :db

      def bulk_insert(klass, values)
        raise NotImplementedError
      end

      def find_untagged_files
        raise NotImplementedError
      end

      def find_tags_without_files
        raise NotImplementedError
      end

      def transaction(&block)
        raise NotImplementedError
      end

      def destroy(klass, options)
        raise NotImplementedError
      end

      def find_one(klass, options)
        raise NotImplementedError
      end

      def find(klass, options)
        raise NotImplementedError
      end

      def save(table, id)
        raise NotImplementedError
      end

      def initialize_db(db_path)
        raise NotImplementedError
      end

      def migrate_db
        raise NotImplementedError
      end

    end
  end
end
