$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "awesome_form/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "awesome_form"
  s.version     = AwesomeForm::VERSION
  s.authors     = ["Cédric Néhémie"]
  s.email       = ["cedric.nehemie@gmail.com"]
  s.homepage    = "https://github.com/abe33/awesome_form"
  s.summary     = "Yet another form handler for rails."
  s.description = "Yet another form handler for rails."

  s.files = Dir[
    "{app/views/awesome_form,lib/awesome_form}/**/*",
    "lib/awesome_form.rb",
    "MIT-LICENSE",
    "Rakefile",
    "README.md"
  ]

  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.2"

  s.add_development_dependency "sqlite3"
end
