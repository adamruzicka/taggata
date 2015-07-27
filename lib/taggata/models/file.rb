module Taggata
  module Models

    class File < Sequel::Model(:taggata_files)

      def path
        ::File.join(parent.path, name)
      end

    end

  end
end
