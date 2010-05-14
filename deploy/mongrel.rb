def rvm(command)
  default_environment = {
    'PATH' => "/nfs/users/nfs_p/psdpipe/.rvm/bin:/nfs/users/nfs_p/psdpipe/.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }/bin:/nfs/users/nfs_p/psdpipe/.rvm/gems/#{ rvm_ruby }@global/bin:/nfs/users/nfs_p/psdpipe/.rvm/rubies/#{ rvm_ruby }/bin:$PATH",
    'RUBY_VERSION' => rvm_ruby,
    
    'GEM_HOME' =>     "/nfs/users/nfs_p/psdpipe/.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }",
    'GEM_PATH' =>     "/nfs/users/nfs_p/psdpipe/.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }:/nfs/users/nfs_p/psdpipe/.rvm/gems/#{ rvm_ruby }@global",
    'BUNDLE_PATH' =>  "/nfs/users/nfs_p/psdpipe/.rvm/gems/#{ rvm_ruby }@#{ rvm_gemset }"
  }
  "env #{ default_environment.map { |v| v.join('=') }.join(' ') } #{ command }"
end

namespace :deploy do
  desc "Custom start task for mongrel cluster"
  task :start, :roles => :app, :except => { :no_release => true }  do
    try_sudo rvm("mongrel_rails cluster::start -C #{ shared_path }/mongrel.yml")
  end

  desc "Custom restart task for mongrel cluster"
  task :restart, :roles => :app, :except => { :no_release => true } do
    try_sudo rvm("mongrel_rails cluster::restart -C #{ shared_path }/mongrel.yml")
  end

  desc "Custom stop task for mongrel cluster"
  task :stop, :roles => :app, :except => { :no_release => true }  do
    try_sudo rvm("mongrel_rails cluster::stop -C #{ shared_path }/mongrel.yml")
  end

  desc "Disable requests to the app, show maintenance page"
  task :disable_web, :roles => :app do
    try_sudo "cp #{current_path}/public/maintenance.html  #{deploy_to}/system/maintenance.html"
  end

  desc "Re-enable the web server by deleting any maintenance file"
  task :enable_web, :roles => :app do
    try_sudo "rm #{deploy_to}/system/maintenance.html"
  end
end
