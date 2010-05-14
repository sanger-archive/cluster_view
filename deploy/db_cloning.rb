namespace :db do
	CONFIG = YAML.load(ERB.new(File.read("config/database.yml")).result)
	#Premature optimization: supports several source environments!
	%w(production staging).each do |src_env|
		desc "Copies schema+data FROM #{src_env} TO target environment"
		task :"clone_from_#{src_env}", :roles => :db, :only => { :primary => true } do 
			on_rollback { delete_tmp_files } #doesn't seem to work :(
			abort "Error: Importing #{src_env.upcase} to #{environment.upcase} is sort of like running in circles..." if environment == src_env
			abort "HOLD IT - we do NOT want to mess with production." if "production" == environment
			
			ENV['src_env'] = src_env
			transaction do
				load_into_database
			end
		end
		after "db:clone_from_#{src_env}", "db:delete_tmp_files"
	end

	task :delete_tmp_files, :roles => :db, :only => { :primary => true } do
		system "rm #{ENV['local_dumpfile']} || true"
		run "rm #{ENV['remote_dumpfile']} || true"
	end
	
	task :load_into_database do
		SRC = CONFIG[ENV['src_env']]
		dumpname = "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{SRC['database']}.sql.gz"
		ENV['remote_dumpfile'] = remote_dumpfile = "/tmp/#{dumpname}"
		
		DST = CONFIG[environment]
		ENV['local_dumpfile'] = local_dumpfile = "#{ENV['TMP'] || '/tmp'}/#{dumpname}"
		
		run <<-END
umask 177
mysqldump -h#{SRC['host']} -P#{SRC['port']} --user=#{SRC['username']} --password=#{SRC['password']} #{SRC['database']} \
| gzip > #{remote_dumpfile}
END
		get "#{remote_dumpfile}", "#{local_dumpfile}"
		
		print "Local dumpfile: "
		system "du -h #{local_dumpfile}"
		answer = "y" if ENV.has_key?("YES")
		answer ||= Capistrano::CLI.ui.ask("You are about to *REPLACE* all data in \"#{environment}\", continue? (y/n?):")
		if answer == "y" 
			system <<-END
mysql -B -h#{DST['host']} -P#{DST['port']} --user=#{DST['username']} --password=#{DST['password']} -e"DROP DATABASE IF EXISTS #{DST['database']};CREATE DATABASE #{DST['database']};"
gzip -dc #{local_dumpfile} | \
mysql -B -h#{DST['host']} -P#{DST['port']} --user=#{DST['username']} --password=#{DST['password']} #{DST['database']}
END
		else
			puts "Alright - aborted."
			run "false"
		end
	end
end
