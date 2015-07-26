module Taggata
  class Scanner

    attr_reader :db, :jobs, :progress

    def initialize(db)
      @db = db
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
      db.transaction do
        jobs << [dir.id, dir.name]
        until jobs.empty?
          do_job *jobs.shift
          report
        end
      end
    end

    def do_job(parent_id, path)
      files, directories = Dir.glob(File.join(path, '*'))
                              .sort
                              .partition { |entry| ::File.file? entry }
      save_missing files.map { |f| ::File.basename f },
                   parent_id,
                   Persistent::File unless files.empty?
      save_missing directories.map { |f| ::File.basename f },
                   parent_id,
                   Persistent::Directory unless directories.empty?
      progress[:files] += files.length
      add_directory_jobs directories,
                         parent_id unless directories.empty?
      progress[:directories] += 1
    end

    def save_missing(files, parent_id, klass)
      in_db = find_in_db(klass, parent_id, files, :name)
      to_save = (files - in_db).map do |basename|
        { :name => basename, :parent_id => parent_id }
      end
      db.adapter.db[klass.table].multi_insert(to_save)
    end

    def find_in_db(klass, parent_id, names, param)
      db.adapter.db[klass.table]
        .where(:parent_id => parent_id)
        .where(:name => names)
        .map(param)
    end

    def add_directory_jobs(dirs, parent_id)
      ids = find_in_db Persistent::Directory,
                       parent_id,
                       dirs.map { |d| ::File.basename d },
                       :id
      ids.zip(dirs).each { |job| jobs << [job.first, job.last] }
    end
  end
end
