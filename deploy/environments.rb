desc "Staging release task"
task :staging do
  set :deploy_name, "clusterview"
  set :environment, "staging"
  set :rails_env, "staging"
  set :deploy_server, "psd1a"
  set :branch_validation_regexp, /\Arelease/
  setup_local
end
desc "Next release release task"
task :next_release do
  set :deploy_name, "clusterview"
  set :environment, "next_release"
  set :rails_env, "next_release"
  set :deploy_server, "psd1a"
  set :branch_validation_regexp, /\Arelease/
  setup_local
end
desc "Production release task"
task :production do
  set :deploy_name, "clusterview"
  set :environment, "production"
  set :rails_env, "production"
  set :deploy_server, "psd1b"
  set :branch_validation_regexp, /\Arelease/
  setup_local
end

desc "Fake environment to test tasks"
task :cap_test do
  set :deploy_name, "clusterview"
  set :environment, "test"
  set :rails_env, "development"
  set :deploy_server, "localhost"
  set :branch_validation_regexp, /\Atest/
  setup_local
  set :deploy_to, "~/test/deploy/#{environment}/#{deploy_name}"
end

task :branch_test do
  set :branch_validation_regexp, /\Atest/
end


task :setup_local do 
  role :web, "#{deploy_server}.internal.sanger.ac.uk"
  role :app, "#{deploy_server}.internal.sanger.ac.uk"
  role :db,  "#{deploy_server}.internal.sanger.ac.uk", :primary => true
  set :deploy_to, "/psg/webapps/#{environment}/#{deploy_name}"
  set :runner, "psdpipe"
  set :admin_runner, runner
  set :branch_validation_regexp, false

  set :rvm_ruby, 'ruby-1.8.6-p383'
  set :rvm_gemset, 'clusterview'

  # Case-specific: yes. Practical: yes.
  PSD_HOME = "/nfs/users/nfs_p/psdpipe/"
  set :default_environment, {
    'HTTP_PROXY' => 'http://wwwcache.sanger.ac.uk:3128/',
    'PATH' => "#{PSD_HOME}.rvm/bin:#{PSD_HOME}.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }/bin:#{PSD_HOME}.rvm/gems/#{ rvm_ruby }@global/bin:#{PSD_HOME}.rvm/rubies/#{ rvm_ruby }/bin:$PATH",
    'RUBY_VERSION' => rvm_ruby,
    
    'GEM_HOME' =>     "#{PSD_HOME}.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }",
    'GEM_PATH' =>     "#{PSD_HOME}.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }:#{PSD_HOME}.rvm/gems/#{ rvm_ruby }@global",
    'BUNDLE_PATH' =>  "#{PSD_HOME}.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }"
  }
end

