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
      unless args[0].nil?
        root_user = args[0][:root_user]
        root_pass = args[0][:pass]
      end

      if root_user.nil? or root_pass.nil?
        $stdout.puts 'mysql user:'
        root_user = $stdin.gets.chomp

        $stdout.puts 'mysql password:'
        system 'stty -echo'
        root_pass = $stdin.gets.chomp
        system 'stty echo'
      end

      return root_user, root_pass
    end

    # creates user permissions for mysql database for localhost only
    def self.create_users(args)
      @root_user, @pass = self.get_input(args)

      # create a mysql user for each listing in database.yml file
      Rails::configuration.database_configuration.each do |listing|
        @config = listing[1]
        username = @config['username']
        db_name = @config['database']

        begin
          db = Mysql2::Client.new( host: 'localhost', username: @root_user, password: @pass)

          sql = self.create_user_sql(@config)
          db.query(sql)

          sql = self.grant_user_sql(@config)
          db.query(sql)

          $stdout.puts "Created #{username} on #{db_name}\n"
        rescue Mysql2::Error => e
          error_output(e)
        ensure # disconnect from server
          db.close if db
        end
      end
    end

    def self.create_user_sql(config)
      return '' unless config

      if config['username'].nil?
        puts 'Error code: missing username entry'
      end

      sql = <<-SQL
        CREATE USER '#{config['username']}'@'localhost' IDENTIFIED BY '#{config['password']}';
      SQL
    end

    def self.grant_user_sql(config)
      return '' unless config

      if config['username'].nil?
        puts 'Error code: missing username entry'
      end

      sql = <<-SQL
        GRANT ALL ON #{config['database']}.* TO '#{config['username']}'@'localhost';
      SQL
    end

    def self.stats
      config = Rails::configuration.database_configuration[Rails.env].clone

      begin
        db = Mysql2::Client.new( host: config['host'], username: config['username'], password: config['password'])

        db_name = config['database']
        version = db.info[:version]

        sql = stats_query(db_name)
        result = db.query sql

      print_header

      db_total = 0
      result.each  do |row|
        print_stat_line(row)
        db_total += row["total_size"].to_i
      end

      print_footer(db_total, db_name, version)
      rescue Mysql2::Error => e
        error_output(e)
      ensure
        db.close if db
      end
    end

    def self.print_separator
      puts  "+--------------------------------+---------------+-----------+----------+------------+"
    end

    def self.print_header
      print_separator
      printf "| %30s | %13s | %9s | %8s | %8s |\n",
        "Table Name".ljust(30), "Rows", "Data Size", "IDX Size", "Total Size"
      print_separator
    end

    def self.print_stat_line(row)
      printf "| %30s | %13s | %9s | %8s | %10s |\n",
        row["table_name"].ljust(30),
        number_to_human(row["table_rows"]).rjust(13),
        number_to_human_size(row["data"]),
        number_to_human_size(row["idx"]),
        number_to_human_size(row["total_size"])
    end

    def self.print_footer(db_total, db_name, version)
      print_separator
      printf "|%70s | %10s |\n",'', number_to_human_size(db_total)
      print_separator
      puts "Database: #{db_name}  MySQL Server Version: #{version}\n"
      puts " "
    end

    def self.stats_query(db_name)
      sql = <<-SQL
          SELECT table_name,
          concat(table_rows) as table_rows,
          concat(data_length) data,
          concat(index_length) idx,
          concat(data_length+index_length) total_size
          FROM information_schema.TABLES
          WHERE table_schema LIKE '#{db_name}'
          ORDER BY table_name;
      SQL
    end

    def self.error_output(e)
      $stdout.puts "Error code: #{e.errno}"
      $stdout.puts "Error message: #{e.error}"
      $stdout.puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    end
  end
end
