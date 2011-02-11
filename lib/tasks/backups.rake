#
# PostgreSQL backup tasks
#
# Dumps database as SQL into a gzip.
#
# Alternatively, you can use rake db:dump to dump to YAML, but that's REALLY
# REALLY slow.
#
# 2/10/11 initial version                                           -jonathanko
#

namespace :db do
namespace :backup do

  def pg_wrapper
    # Used to wrap some statements inside a PGPASSWORD=whatever, so that
    # you can use pg_dump or psql.
    # Passes Rails database config for current environment to a block.
    # Usage: pg_wrapper do |config|
    #          # PGPASSWORD is set
    #          system "pg_dump blah --user #{config['username']}"
    #        end
    #        # PGPASSWORD is now blank
    #
    begin
      config = Rails.configuration.database_configuration[RAILS_ENV]
      ENV['PGPASSWORD'] = config["password"]
      yield config
     rescue => e
      puts "ERROR: #{e}"
    ensure
      ENV['PGPASSWORD'] = ''
    end
  end

  # Backup
  # rake db:backup:dump[filename]
  # rake db:backup:dump TO=filename
  # rake db:backup:dump             => db/backups/db__date__time.gz
  desc "Backs up the database into $DBBAK, default db/backups/`date`.gz"
  task :dump, :filename do |t,args|
    filename = args[:filename] || ENV['TO'] || File.join('db','backups', "#{config['database']}__#{Time.now.strftime "%Y_%m_%d__%H_%M_%S"}.gz")
    puts "Dumping into #{filename}"

    pg_wrapper do |config|
      Dir.mkdir File.dirname(filename) unless File.directory? File.dirname(filename)
      success = system "pg_dump #{config['database']} --user #{config['username']} | gzip > \"#{filename}\""
      raise "pg_dump error!" unless success
      puts "Done.\n"
    end
  end

  # Restore
  # rake db:backup:restore[filename]
  # rake db:backup:restore FROM=filename
  desc "Restores the database."
  task :restore, :filename do |t,args|
    filename = args[:filename] || ENV['FROM']
    raise "Usage: rake db:backup:restore[filename] | db:backup:restore FROM=filename" if filename.blank?
    raise "Can't find #{filename}" unless File.file?(filename)
    pg_wrapper do |config|
      puts "Loading from #{filename}"
      success = system "gunzip -c #{filename} | psql #{config['database']} --user #{config['username']}"
      raise "psql error!" unless success
      puts "Done.\n"
    end
  end

end # backup
end # db
