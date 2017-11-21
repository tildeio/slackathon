$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "slackathon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "slackathon"
  s.version     = Slackathon::VERSION
  s.authors     = ["Godfrey Chan", "Yehuda Katz", "Krystan HuffMenne"]
  s.email       = ["godfreykfc@gmail.com", "wycats@gmail.com", "krystan@tilde.io"]
  s.homepage    = "https://github.com/tildeio/slackathon"
  s.summary     = "A simple way to build Slack interations inside a Rails app."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"
end
