require File.expand_path('../../lib/mysql_rake_tasks/tasks',__FILE__)

require 'test/unit'
require 'stringio'
require 'mocha'

class TasksTest < Test::Unit::TestCase

  def test_two_args_returns_two_values
    output = MysqlRakeTasks::Tasks::get_input({:root_user => 'user', :pass => 'pass'})

    assert_equal 2, output.length
    assert_equal 'user', output[:root_user]
    assert_equal 'pass', output[:pass]
  end

  def test_lack_of_args_invokes_cli_interface
    output = ""
    screen = io_mock do |input|
               input.string = "root\nmypassword\n"
               output = MysqlRakeTasks::Tasks.get_input
             end

    assert_equal 'mysql user:', screen[0]
    assert_equal 'mysql password:', screen[1]
    assert_equal 'root', output[:root_user]
    assert_equal 'mypassword', output[:pass]
  end


  def test_unsuccessful_authentication
    Rails.stubs(:configuration).returns(Rails::Application::Configuration.allocate) 
    Rails.configuration.stubs(:database_configuration).returns(stub_config)

    screen = io_mock do |input|
      MysqlRakeTasks::Tasks.create_users(:root_user => 'root', :pass => 'wrong')
    end
   
    assert_equal 'Error code: 1045', screen[0]
    assert_equal "Error message: Access denied for user 'root'@'localhost' (using password: YES)", screen[1]
    assert_equal 'Error code: 1045', screen[2]
    assert_equal "Error message: Access denied for user 'root'@'localhost' (using password: YES)", screen[3]
    assert_equal 'Error code: 1045', screen[4]
    assert_equal "Error message: Access denied for user 'root'@'localhost' (using password: YES)", screen[5]
  end

  def test_successful_creation
    Rails.stubs(:configuration).returns(Rails::Application::Configuration.allocate)
    Rails.configuration.stubs(:database_configuration).returns(stub_config)

    screen = io_mock do |input|
      # :pass needs to be set to mysql root in order to pass
      MysqlRakeTasks::Tasks.create_users(:root_user => 'root', :pass => 'myrootpass') 
    end

    assert_equal "Created dev on task_development", screen[0], 'Note: ***check test machine password***'
    assert_equal "Created test on task_test", screen[1]
    assert_equal "Created prod on task_production", screen[2]
  end

  def test_lack_of_user_throws_error
    config = stub_config
    config["development"].delete "username"

    Rails.stubs(:configuration).returns(Rails::Application::Configuration.allocate)
    Rails.configuration.stubs(:database_configuration).returns(config)

    screen = io_mock do |input|
      # :pass needs to be set to mysql root in order to pass
      MysqlRakeTasks::Tasks.create_users(:root_user => 'root', :pass => 'myrootpass')
    end

    assert_equal 'Error code: missing username entry', screen[0], 'Note: ***check test machine password***'
    assert_equal 'Error code: 1064', screen[1]
  end

  def stub_config
   {"development"=>{"adapter"=>"mysql2",
                    "encoding"=>"utf8",
                    "reconnect"=>false,
                    "database"=>"task_development",
                    "pool"=>5,
                    "username"=>"dev",
                    "password"=>"devpassword"},
   "test"=>{"adapter"=>"mysql2",
            "encoding"=>"utf8",
            "reconnect"=>false,
            "database"=>"task_test",
            "pool"=>5,
            "username"=>"test",
            "password"=>"taskpassword"},
   "production"=>{"adapter"=>"mysql2",
                  "encoding"=>"utf8",
                  "reconnect"=>false,
                  "database"=>"task_production",
                  "pool"=>5,
                  "username"=>"prod",
                  "password"=>"prodpassword"}} 
  end


  def io_mock
    org_stdin = $stdin
    org_stdin = $stdout

    $stdin = StringIO.new
    $stdout = StringIO.new

    yield $stdin

    return $stdout.string.split("\n")
  ensure
    $stdin = org_stdin
    $stdout = org_stdin
  end
end