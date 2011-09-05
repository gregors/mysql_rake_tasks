require 'rails'
require 'mysql2'

module MysqlRakeTasks
  class Tasks

    # Parses input args for username and password, if not given
    # it will prompt the user
    def self.get_input(*args)
      if !args[0].nil? then
        root_user = args[0][:root_user]
        root_pass = args[0][:pass]
      end

      if root_user.nil? or root_pass.nil? then
        $stdout.puts 'mysql user:'
        root_user = $stdin.gets.chomp

	$stdout.puts 'mysql password:'
        system 'stty -echo'
        root_pass = $stdin.gets.chomp
        system 'stty echo'
      end

      {:root_user => root_user, :pass => root_pass}
    end

    # creates user permissions for mysql database for localhost only 
    def self.create_users(args)
      args = self.get_input(args)
      @root_user = args[:root_user]
      @pass = args[:pass]

      # create a mysql user for each listing in database.yml file
      Rails::configuration.database_configuration.each do |listing|
        begin
  	  @config = listing[1]
          db = Mysql2::Client.new(
               :host => 'localhost',
               :username => @root_user,
               :password => @pass,
               :socket => @config['socket'])

          sql = self.create_user_sql(@config)
          db.query sql
	  $stdout.puts "Created #{@config['username']} on #{@config['database']}\n"
        rescue Mysql2::Error => e
          $stdout.puts "Error code: #{e.errno}"
          $stdout.puts "Error message: #{e.error}"
          $stdout.puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
        ensure # disconnect from server 
          db.close if db
        end
      end
    end

    def self.create_user_sql(config)
      if config.nil? then
        return ""
      end

      if config['username'].nil? then
        puts 'Error code: missing username entry'
      end

      sql  = <<-SQL
        GRANT
        ALL PRIVILEGES
        ON #{config['database']}.*
        TO #{config['username']}@localhost
        IDENTIFIED BY '#{config['password']}';
      SQL
    end

  end
end

