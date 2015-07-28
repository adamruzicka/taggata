module Taggata
  class Scanner

    attr_reader :jobs, :progress

    def initialize
      @jobs = []
      @progress = { :files => 0, :directories => 0 }
    end

    def report_header
      puts "Files\tDirectories\tQueued"
    end

    def report
      puts "#{progress[:files]}\t#{progress[:directories]}\t\t#{jobs.length}"
    end

    def process(dir)
      report_header
      jobs << [dir.id, dir.name]
      until jobs.empty?
        do_job *jobs.shift
        report
      end
    end

    def do_job(parent_id, path)
      files, directories = Dir.glob(File.join(path, '*'))
                              .sort
                              .partition { |entry| ::File.file? entry }

      files.each do |file|
        Models::File.find_or_create(:name => ::File.basename(file),
                                    :parent_id => parent_id)
      end
      progress[:files] += files.length

      directories.each do |dir|
        Models::Directory.find_or_create(:name => ::File.basename(dir),
                                         :parent_id => parent_id)
      end

      add_directory_jobs directories,
                         parent_id unless directories.empty?
      progress[:directories] += 1
    end

    def add_directory_jobs(dirs, parent_id)
      names = dirs.map { |dir| ::File.basename dir }
      ids = Models::Directory.where(:parent_id => parent_id)
                             .where(:name => names)
                             .map(&:id)
      ids.zip(dirs).each { |job| jobs << [job.first, job.last] }
    end
  end
end
