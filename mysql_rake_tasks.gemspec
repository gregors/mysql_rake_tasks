# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mysql_rake_tasks/version"

Gem::Specification.new do |s|
  s.name        = "mysql_rake_tasks"
  s.version     = MysqlRakeTasks::VERSION
  s.date        = 
  s.authors     = ["Gregory Ostermayr"]
  s.email       = ["gregory.ostermayr@gmail.com"]
  s.homepage    = "https://github.com/gregors"
  s.summary     = %q{Rake tasks for mysql}
  s.description = %q{A collection mysql rails rake tasks for mysql.}
  s.license = "MIT"
  s.extra_rdoc_files = [
   "LICENSE",
   "README.rdoc"
  ]

  s.rubyforge_project = "mysql_rake_tasks"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = Dir['test/*.rb'] 
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_runtime_dependency "mysql2"
end
