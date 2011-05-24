# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'em-modbus/version'
 
Gem::Specification.new do |s|
  s.name        = "em-modbus"
  s.version     = EmModbus::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tallak Tveide"]
  s.email       = ["tallak@tveide.net"]
  s.homepage    = "http://github.com/tallakt/em-modbus"
  s.summary     = "Modbus TCPIP driver with data image based on eventmachine"
  s.description = "PROTOTYPE DONT USE"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.add_dependency "eventmachine"

  s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{bin,lib,spec}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md Rakefile)
  s.executables  = []
  s.require_path = 'lib'
end
