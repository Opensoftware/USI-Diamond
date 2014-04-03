$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "diamond/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diamond"
  s.version     = Diamond::VERSION
  s.authors     = ["opensoftware.pl"]
  s.email       = ["contact@opensoftware.pl"]
  s.homepage    = "mine.opensoftware.pl"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.4"

end
