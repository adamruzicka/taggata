module Taggata
  module Models

    class File < Sequel::Model(:taggata_files)

      def path
        ::File.join(parent.path, name)
      end

      def add_tags(*tags)
        Taggata::Database.transaction do
          tags.each { |tag| add_tag tag }
        end
      end

      def remove_tags(*tags)
        Taggata::Database.transaction do
          tags.each { |tag| remove_tag tag }
        end
      end

    end

  end
end
