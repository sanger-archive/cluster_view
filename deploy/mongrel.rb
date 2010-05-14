def rvm(command)
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
