module Taggata
  class FilesystemScanner
    # Initialize scanner's internal objects and default tag
    def initialize
      @all = 1
      @jobs = []
      @done = 0
      @tag = ::Taggata::Tag.find_or_create(:name => 'default')
    end

    # Report progress
    def report
      puts "Done/All - Queued: #{@done}/#{@all} - #{@jobs.length}"
    end

    # Process directory at full path
    #
    # @param dir String name of the directory
    # @param path String full path of the directory
    def do_job(dir, path)
      Dir.glob("#{path}/*") do |child|
        if ::File.file? child
          ::Taggata::File.find_or_create(:name => ::File.basename(child),
                                         :parent_id => dir.id).add_tag @tag
          @done += 1
        else
          d = [::Taggata::Directory
               .find_or_create(:name => ::File.basename(child),
                               :parent_id => dir.id),
               child]
          @jobs << d
        end
        @all += 1
      end
    end

    # Breadth first search traversal through the filesystem tree
    def process(dir)
      do_job dir, dir.name
      until @jobs.empty?
        report
        do_job(*@jobs.shift)
        @done += 1
      end
    end
  end
end
