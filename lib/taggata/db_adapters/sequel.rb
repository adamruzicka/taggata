module Taggata
  module DbAdapters

    Sequel.extension :migration

    class Sequel < Abstract

      def bulk_insert(klass, values)
        db[klass.table].multi_insert(values)
      end

      def transaction(block)
        db.transaction do
          block.call
        end
      end

      def find_untagged_files
        file_tags = db[Persistent::FileTag.table].select(:file_id).map { |hash| hash[:file_id] }
        file_ids = db[Persistent::File.table].select(:id).map { |hash| hash[:id] }
        untagged_ids = file_ids.reject { |id| file_tags.include? id }
        find(Taggata::Persistent::File, :id => untagged_ids)
      end

      def destroy(klass, options)
        db[klass.table].where(options).delete
      end

      def find(klass, options)
        db[klass.table].where(options).all
      end

      def find_one(klass, options)
        db[klass.table].where(options).limit(1).first
      end

      def search(klass, options)
        db[klass.table].where(options)
      end

      def save(table, hash)
        existing_record = db[table].where(primary_key(table, hash)).limit(1)
        if existing_record.count == 0
          db[table].insert(hash)
        else
          existing_record.update(hash)
        end
      end

      def initialize_db(db_path)
        @db = ::Sequel.connect db_path
      end

      def migrate_db
        ::Sequel::Migrator.run(db, self.class.migrations_path, table: 'taggata_schema_info')
      end

      private

      def primary_key(table, hash)
        case table
        when :taggata_file_tags
          { :file_id => hash[:file_id], :tag_id => hash[:tag_id] }
        else
          { :id => hash[:id] }
        end
      end

      def self.migrations_path
        File.expand_path('../sequel_migrations', __FILE__)
      end

    end
  end
end
