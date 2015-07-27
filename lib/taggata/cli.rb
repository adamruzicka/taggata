module Taggata
  module Cli

    require 'clamp'
    require 'sequel'
    require 'taggata/database'
    require 'taggata/cli/commands'

    Clamp do

      option "--db-path", "DB_PATH", "path to the DB", :attribute_name => :db, :required => true do |db_path|
        Taggata::Database.initialize(:sqlite, db_path)
        require 'taggata'
      end

      option %w(-v --verbose), :flag, 'be verbose', :default => false
      option %w(-q --quiet),   :flag, 'be quite',   :default => false

      subcommand 'cleanup', 'Remove stale entries from the database', CleanupCommand

      subcommand 'list', 'List things in database', ListCommand

      subcommand 'remove', 'Remove files matching query', RemoveCommand

      subcommand 'scan', 'Scan the system', ScanCommand

      subcommand 'search', "Search the database", SearchCommand

      subcommand 'tag', 'Tag a file matching query', TagCommand

    end
  end
end
