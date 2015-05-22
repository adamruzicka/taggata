module Taggata
  class FilesystemScanner
    # Initialize scanner's internal objects and default tag
    def initialize
      @jobs = []
      @done_files = 0
      @done_directories = 0
    end

    # Report progress
    def report
      print 'Done files/dirs - Queued: ',
            "#{@done_files}/#{@done_directories} ",
            "- #{@jobs.length}\n"
    end

    # Process directory at full path
    #
    # @param dir String name of the directory
    # @param path String full path of the directory
    def do_job(dir_id, path)
      contents = Dir.glob("#{path}/*")
                 .reduce(::Taggata::File => [],
                         ::Taggata::Directory => []) do |acc, cur|
        key = ::File.file?(cur) ? ::Taggata::File : ::Taggata::Directory
        acc.merge(key => acc[key].push(cur))
      end

      contents.each_pair do |klass, files|
        save_missing files.map { |f| ::File.basename f },
                     dir_id,
                     klass unless files.empty?
      end
      @done_files += contents[::Taggata::File].length
      add_directory_jobs contents[::Taggata::Directory],
                         dir_id unless contents[::Taggata::Directory].empty?
      @done_directories += 1
    end

    def add_directory_jobs(dirs, parent_id)
      ids = find_in_db ::Taggata::Directory,
                       parent_id,
                       dirs.map { |d| ::File.basename d },
                       :id
      ids.zip(dirs).each { |job| @jobs << job }
    end

    def save_missing(files, parent_id, klass)
      in_db = find_in_db(klass, parent_id, files, :name)
      to_save = (files - in_db).map do |basename|
        { :name => basename, :parent_id => parent_id }
      end
      klass.dataset.multi_insert(to_save)
    end

    def find_in_db(klass, parent_id, names, param)
      klass
        .where(:parent_id => parent_id)
        .where(:name => names)
        .map(param)
    end

    # Breadth first search traversal through the filesystem tree
    def process(dir)
      @jobs << [dir.id, dir.name]
      until @jobs.empty?
        do_job(*@jobs.shift)
        report
      end
    end
  end
end
