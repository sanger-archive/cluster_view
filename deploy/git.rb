require 'date'

def get_current_branch_and_remote
	#TODO move that in a other task, before
	branch = find_current_branch
	@variables[:branch]= branch
	if branch =~ /([^\/]+)\/([^\/]+)/
		remote, branch = [$1, $2]
	else
		remote = 'origin'
	end
  [branch, remote]
end

task :checkit do
	env = @variables[:environment]
	raise Exception, "no environment specified" unless env

  branch, remote = get_current_branch_and_remote

  check_good_branch(branch)

  if branch_validation_regexp # if not we don't check
    check_good_number(branch)
    last_branch, last_version = last_valid_branch
    raise Exception, "The version of the branch you are trying to deploy is lesser than '#{last_branch}'" if last_branch && last_branch != branch
  end

	now = DateTime.now
	tag_name =  compute_tag_stamp(now, env)
	current_commit = find_commit(branch, remote)


	raise Exception, "your current version is different from what you are trying to deploy. Maybe you have forgotten to push your modifications. Otherwise, checkout the version you are willing to deploy." unless diff_version("HEAD", current_commit)

	#for the tagit task
	@last_tag = "#{env}/last"
	@tag_name = tag_name
	@current_commit = current_commit
	@remote = remote

end
task :tagit do
	tag_remotely(@tag_name, @current_commit, @remote)
	tag_remotely(@last_tag, @tag_name, @remote, '-f')
end

desc "use it to skip the branch validation"
task :skip_branch_name_validation do
  set :branch_validation_regexp, nil
end

task :versionit do
  branch, remote = get_current_branch_and_remote
  info = extract_branch_info(branch)
  if info
    branch, version = info
    buffer =<<EOR
module Deployed
  Revision = [ #{version.join", "}]
end
EOR
    put buffer, "#{current_path}/lib/deployed_version.rb"
  end
end


def find_current_branch
	`git branch | sed -n 's/^\\* //p'`.chomp
end

def compute_tag_stamp(date,environment_name)
	date.strftime "#{environment_name}/%Y-%m-%d/%H-%M-%S"
end

def diff_version(ref1, ref2)
	system "git diff --quiet #{ref1} #{ref2}"
end

def find_commit(branch, remote)
	#TODO see if capistrano can do it.
	system "git fetch #{remote} #{branch}"
	"#{remote}/#{branch}"
end

def tag_remotely(tag_name, commit_name, remote, options='')
	system "git tag #{options} #{tag_name} #{commit_name}"
	system "git push #{remote} #{tag_name}"

end

def extract_branch_info(branch_name)
  if branch_name =~ /(.+?)-?(\d+(?:\.\d+)+)/
    return $1, $2.split('.').map {|c| c.to_i}
  end
end

task :get_branch_info do
  puts extract_branch_info(find_current_branch)
end

def check_good_branch (full_branch)
  branch_validation_regexp = @variables[:branch_validation_regexp]
  branch_validation_regexp = /#{branch_validation_regexp}/ if branch_validation_regexp.is_a?(String)
  return unless branch_validation_regexp
  branch_info = extract_branch_info(full_branch)
  if branch_info 
    branch, version = branch_info
  else
    branch = full_branch
  end
  raise Exception, "current branch '#{branch}' doesn't match valid branch : /#{branch_validation_regexp}/" unless branch =~ branch_validation_regexp
  return true
end

def check_good_number(full_branch)
  branch_info = extract_branch_info(full_branch)
  raise Exception, "current branch doesn't have any revision number" unless branch_info and branch_info[1]
end

def remove_tag_remotely(tag_name, remote)
	system "git push :#{remote} #{tag_name}"
end

before"deploy:update_code", :checkit
after"deploy", :tagit, :versionit


def last_valid_branch
  last_branch = nil
  last_version = nil
  return unless  branch_validation_regexp
  `git branch -a | sed 's/^[* ]*//'`.each_line do |line|
    branch_name = line.chomp
    branch_info = extract_branch_info(branch_name)
    next unless branch_info
    branch, version = branch_info
    next unless branch_name  =~ branch_validation_regexp

    #compare versions
    greater = true
    if last_version
      pad_number = [last_version.size - version.size, 0].max
      (version + [nil]*pad_number).zip(last_version).each do |v, l|
        break if l == nil
        if v == nil || v < l
          greater = false
          break
        end
      end
    end
    if greater
      last_branch = branch_name
      last_version = version
    end
  end

  return [last_branch,  last_version]
end

desc "display the branch name corresponding to the last version number for a specific environment"
task :last_version do
  last_branch , last_version = last_valid_branch
  puts (last_branch ? "*** Last deployed branch '#{last_branch}' ***" : "*** No deployed branch found with a valid version number")
end
