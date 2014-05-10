name = "autolang"
require "./lib/autolang/version"

Gem::Specification.new name, Autolang::VERSION do |s|
  s.summary = "Kick-start new translation via google translate"
  s.authors = ["Chris Blackburn", "Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib MIT-LICENSE.txt`.split("\n")
  s.license = "MIT"
  s.add_runtime_dependency 'i18n'
  s.add_runtime_dependency 'easy_translate'
  s.add_runtime_dependency 'json'
  s.executables = ["autolang"]
end
