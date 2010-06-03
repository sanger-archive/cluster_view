def rvm(command)
  "env HOME=$(echo ~#{runner}) #{ default_environment.map { |v| v.join('=') }.join(' ') } #{ command }"
end

namespace :deploy do
  [:start, :stop, :restart].each do |task_name|
    desc "RVM-aware #{task_name} task for mongrel cluster"
    task task_name, :roles => :app, :except => { :no_release => true } do
      try_sudo rvm("mongrel_rails cluster::#{task_name} -C #{ shared_path }/mongrel.yml")
    end
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
task :check_rvm do
  try_sudo rvm("rvm info")
end
before "deploy:check", "check_rvm"
