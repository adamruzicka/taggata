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
          Models::File.each { |f| puts f.path }
        when :directory
          Models::Directory.each { |d| puts d.path }
        when :tag
          Models::Tag.each { |t| puts t.name }
        end
      end

    end
  end
end
