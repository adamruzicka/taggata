module Taggata
  module Persistent
    module WithParent

      def parent
        Directory.find_one db, :id => parent_id
      end

    end
  end
end
