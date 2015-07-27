module Taggata
  class Database
    class << self

      def initialize(db_type, db_path)
        Sequel.extension :migration
        @@db = connect(db_type, db_path)
        run_migrations
        Sequel::Model.db = @@db
      end

      def connect(db_type, db_path)
        case db_type
        when :sqlite
          Sequel.connect("#{db_type.to_s}://#{db_path}")
        else
          raise "Unsupported database type."
        end
      end

      def transaction(&block)
        raise "A block must be provided to run in transaction." unless block_given?
        @@db.transaction do
          block.call
        end
      end

      private

      def run_migrations
        ::Sequel::Migrator.run(@@db, migrations_path, table: 'taggata_schema_info')
      end

      def migrations_path
        File.expand_path('../sequel_migrations', __FILE__)
      end
    end
  end
end
