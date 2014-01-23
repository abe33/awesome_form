$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "awesome_ui/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "awesome_ui"
  s.version     = AwesomeUi::VERSION
  s.authors     = ["Cédric Néhémie"]
  s.email       = ["cedric.nehemie@gmail.com"]
  s.homepage    = "https://github.com/abe33/awesome_form"
  s.summary     = "A theme for AwesomeForm"
  s.description = "A theme for AwesomeForm"

  s.files = Dir[
    "{app/**/awesome_ui,lib/awesome_ui}/**/*",
    "lib/awesome_ui.rb",
    "MIT-LICENSE",
    "README.md"
  ]

  s.add_dependency "awesome_form", AwesomeForm::VERSION
end
