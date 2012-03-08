# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "validation_kit/version"

Gem::Specification.new do |s|
  s.name        = "validation_kit"
  s.version     = ValidationKit::VERSION
  s.authors     = ["Wes Morgan", "Paul Schreiber"]
  s.email       = ["wes@turbovote.org", "paul@turbovote.org"]
  s.homepage    = "https://github.com/turbovote/validation_kit"
  s.summary     = %q{Handy validations for Rails forms}
  s.description = %q{A collection of various validators for Rails forms}

  s.rubyforge_project = "validation_kit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
