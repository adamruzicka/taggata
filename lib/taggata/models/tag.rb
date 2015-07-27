module Taggata
  module Models

    class Tag < Sequel::Model(:taggata_tags)

      def add_untagged_files(to_add)
        Models::File.where(:id => to_add.map(&:id))
                    .exclude(:id => files.map(&:id))
                    .each { |file| add_file file }
      end

    end

  end
end
