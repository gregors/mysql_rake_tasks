require 'rails'
require 'mysql2'

# test unit seems to need these
require 'active_support'
require 'action_view'

include ActionView::Helpers::NumberHelper

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

    def self.stats
      config = Rails::configuration.database_configuration[Rails.env]

      begin
        dbh = Mysql2::Client.new( :host => config['host'], :username => config['username'], :password => config['password'])
        sql = stats_query(config['database'])
        result = dbh.query sql

        print_header
        db_total = 0
        result.each  do |row|
          printf "| %30s | %13s | %9s | %8s | %10s |\n",
            row["table_name"].ljust(30),
            number_to_human(row["rows"]).rjust(13),
            number_to_human_size(row["data"]),
            number_to_human_size(row["idx"]),
            number_to_human_size(row["total_size"])

	  db_total += row["total_size"].to_i
        end

        print_separator
        printf "|%70s | %10s |\n",'',  number_to_human_size(db_total)
        print_separator
        puts "Database: #{config['database']}  MySQL Server Version: #{dbh.info[:version]}\n"
        puts " "
      rescue Mysql2::Error => e
        puts "Error code: #{e.errno}"
        puts "Error message: #{e.error}"
        puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      ensure
        dbh.close if dbh
      end
    end

    def self.print_separator
      puts   "+--------------------------------+---------------+-----------+----------+------------+"
    end

    def self.print_header
      print_separator
      printf "| %30s | %13s | %9s | %8s | %8s |\n",
        "Table Name".ljust(30), "Rows", "Data Size", "IDX Size", "Total Size"
       print_separator
    end

    def self.stats_query(db_name)
      sql = <<-SQL
          SELECT table_name,
          concat(table_rows) rows,
          concat(data_length) data,
          concat(index_length) idx,
          concat(data_length+index_length) total_size
          FROM information_schema.TABLES
          WHERE table_schema LIKE '#{db_name}'
          ORDER BY table_name;
      SQL
    end
  end
end
