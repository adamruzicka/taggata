module Taggata
  module Persistent
    class Abstract

      def save
        @id ||= db.save(self)
      end

      def self.destroy(db, options)
        db.destroy(self, options)
      end

      def destroy(options = {})
        db.destroy(self.class, self.to_hash)
      end

      def self.find_one(db, options)
        db.find_one(self, options)
      end

      def self.bulk_insert(db, values)
        db.bulk_insert(self, values)
      end

      def self.find(db, options)
        db.find(self, options)
      end

      def self.find_or_create(db, options)
        db.find_or_create(self, options)
      end

      def invalidate_cache
      end

      def to_hash
        raise NotImplementedError
      end

      def self.new_from_hash(db, hash)
        raise NotImplementedError
      end

      def self.table
        raise NotImplementedError
      end

      def show(indent = 0)
      end

    end
  end
end
