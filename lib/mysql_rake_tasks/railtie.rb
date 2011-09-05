require 'rails'

module MysqlRakeTasks
  class Railtie < Rails::Railtie

    rake_tasks do
      load "mysql_rake_tasks/mysql_rake_tasks.rake"
    end
  end
end
