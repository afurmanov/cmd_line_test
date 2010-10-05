# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "cmd_line_test"
  s.version     = "0.1.6"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aleksandr Furmanov"]
  s.email       = ["aleksandr.furmanov@gmail.com"]
  s.homepage    = "http://github.com/afurmanov/cmd_line_test"
  s.summary     = %{Extends Shoulda or Test::Unit with macros for testing command line apps}
  s.description = %{Extends Shoulda or Test::Unit with macros for testing command line apps}
  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "shoulda"
  s.files = Dir["[A-Z]*", "{lib,test}/**/*"]
end
