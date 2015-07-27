module Taggata
  module Cli
    class ListCommand < Clamp::Command

      parameter 'TYPE', 'type of records to list, can be one of file, directory, tag', :attribute_name => :type, :required => true do |type|
        signal_usage_error 'TYPE must be one of file, directory, tag' unless %(file directory tag).include? type
        type.to_sym
      end
      
      def execute
        case type
        when :file
          @db.find(Taggata::Persistent::File, {}).each { |file| puts file.path }
        when :directory
          @db.find(Taggata::Persistent::Directory, {}).each { |dir| puts dir.path }
        when :tag
          @db.find(Taggata::Persistent::Tag, {}).each { |tag| puts tag.name }
        end
      end

    end
  end
end
