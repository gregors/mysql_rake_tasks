namespace :db do
  namespace :mysql do

    desc "Create MySQL users from database.yml (localhost only). Run without parameters for interactive mode."
    task :create_users, [:root_user, :pass] do |rake_task, args|
      MysqlRakeTasks::Tasks::create_users(args)
    end

    desc "Display MySQL stats"
    task :stats =>  [:environment] do |rake_task, args|
      MysqlRakeTasks::Tasks::stats
    end
  end
end


