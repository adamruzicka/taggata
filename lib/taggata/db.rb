module Taggata
  class Db

    attr_reader :adapter

    def initialize(db_path, adapter_class)
      @adapter = adapter_class.new
      @adapter.initialize_db db_path
      @adapter.migrate_db
    end

    def transaction(&block)
      if block_given?
        adapter.transaction(block)
      else
        raise "Cannot initiate transaction without block."
      end
    end

    def find_untagged_files
      adapter.find_untagged_files.map { |hash| Persistent::File.new_from_hash self, hash }
    end

    def destroy(klass, options)
      adapter.destroy(klass, options)
    end

    def bulk_insert(klass, values)
      adapter.bulk_insert(klass, values)
    end

    def find(klass, options = {})
      adapter.find(klass, options).map do |hash|
        klass.new_from_hash self, hash
      end
    end

    def find_one(klass, options = {})
      record = adapter.find_one(klass, options)
      klass.new_from_hash(self, record) unless record.nil?
    end

    def load(klass, id)
      klass.new_from_hash(adapter.load(klass, id))
    end

    def find_or_create(klass, options)
      search = adapter.find_one(klass, options)
      if search.nil?
        o = klass.new_from_hash self, options
        o.save
        o
      else
        klass.new_from_hash self, search
      end
    end

    def save(object)
      adapter.save(object.class.table, object.to_hash)
    end

    def find_child_directories(directory)
      adapter.find(Persistent::Directory, :parent_id => directory.id).map do |hash|
        Persistent::Directory.new_from_hash(self, hash)
      end
    end

    def find_child_files(directory)
      adapter.find(Persistent::File, :parent_id => directory.id) do |hash|
        Persistent::File.new_from_hash(self, hash)
      end
    end

  end
end
