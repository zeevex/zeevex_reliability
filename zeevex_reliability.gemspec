# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "zeevex_reliability/version"

Gem::Specification.new do |s|
  s.name        = "zeevex_reliability"
  s.version     = ZeevexReliability::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Sanders"]
  s.email       = ["robert@zeevex.com"]
  s.homepage    = ""
  s.summary     = %q{Utility functions to automate retry loops}
  s.description = %q{Includes a general and an ActiveRecord StaleObject-focused retry loop}

  s.rubyforge_project = "zeevex_reliability"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'rspec', '~> 2.9.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'activerecord', '~> 2.3.0'
end
