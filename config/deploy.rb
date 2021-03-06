set :application, "rubychat"
set :repository,  "git://github.com/alphonse23/rubychat.git"
set :scm, :git
set :user, "webuser"
set :use_sudo, false

set :deploy_to, "/home/webuser/rubychat"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "ec2-54-241-235-11.us-west-1.compute.amazonaws.com"                          # Your HTTP server, Apache/etc
role :app, "ec2-54-241-235-11.us-west-1.compute.amazonaws.com"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

namespace :deploy do
  desc "Override deploy:cold to NOT run migrations - there's no database"
  task :cold do
    update
    start
  end
end
