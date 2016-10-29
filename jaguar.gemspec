require File.expand_path("../lib/jaguar/version", __FILE__)
Gem::Specification.new do |gem|
  gem.name          = "jaguar"
  gem.version       = Jaguar::VERSION
  gem.license       = "MIT"
  gem.authors       = ["Tiago Cardoso"]
  gem.email         = ["cardoso_tiago@hotmail.com"]
  gem.description   = "Evented HTTP Server"
  gem.summary       = "Evented Server for HTTP"
  gem.homepage      = "http://github.com/TiagoCardos1983/jaguar"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency "celluloid-io", ">= 0.17"
  gem.add_dependency "http_parser.rb"#,  "~> 0.6.0"
end
