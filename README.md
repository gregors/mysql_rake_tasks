# mysql_rake_tasks

A collection of rails rake tasks for mysql
1. create_users - creates localhost mysql user accounts for each database listing in the database.yml
2. stats - database stats - table size

## Install

1. Add mysql_rake_tasks to your gem file

  gem 'mysql_rake_tasks', '~> 0.1.0'

2. Run the bundle command

  bundle install

## Examples

### create_users

To create mysql users in interactive mode run:

  rake db:mysql:create_users
  mysql user: root
  mysql pass:

You can also specify your root username and password on the command line:

  rake db:mysel:create_users[root,mypassword]

### stats

To display database stats:

  rake db:mysql:stats
  +--------------------------------+---------------+-----------+----------+------------+
  | Table Name                     |          Rows | Data Size | IDX Size | Total Size |
  +--------------------------------+---------------+-----------+----------+------------+
  | fish                           |  1.41 Million |   93.6 MB |  41.1 MB |     135 MB |
  | birds                          |             0 |     16 KB |  0 Bytes |      16 KB |
  | cats                           |            14 |     16 KB |  0 Bytes |      16 KB |
  | schema_migrations              |             7 |     16 KB |  0 Bytes |      16 KB |
  | users                          |             5 |     16 KB |    32 KB |      48 KB |
  +--------------------------------+---------------+-----------+----------+------------+
  |                                                                       |     135 MB |
  +--------------------------------+---------------+-----------+----------+------------+
  Database: mydb_development  MySQL Server Version: 5.1.58

## License

MIT

## Credits

Author: Gregory Ostermayr gregory.ostermayr@gmail.com

Contributed code and/or ideas:

Kevin Woods

Travis Herrick

