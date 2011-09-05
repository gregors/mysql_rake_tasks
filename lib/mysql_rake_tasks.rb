require 'mysql_rake_tasks/version'

module MysqlRakeTasks
  require "mysql_rake_tasks/railtie" if defined?(Rails)
  require "mysql_rake_tasks/tasks"
  require 'mysql2'
end
