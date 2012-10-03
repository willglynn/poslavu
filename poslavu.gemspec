# -*- encoding: utf-8 -*-
require File.expand_path('../lib/poslavu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Will Glynn"]
  gem.email         = ["will@willglynn.com"]
  gem.description   = %q{POSLavu is a hosted point-of-sale system. The `poslavu` gem provides access to the API.}
  gem.summary       = %q{POSLavu API client}
  gem.homepage      = "http://github.com/willglynn/poslavu"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "poslavu"
  gem.require_paths = ["lib"]
  gem.version       = POSLavu::VERSION

  gem.add_dependency "nokogiri", "~> 1.5"
  gem.add_dependency "faraday", "~> 0.8"
  gem.add_dependency "multi_json", "~> 1.3"

  gem.add_development_dependency "bundler", "~> 1.1"
  gem.add_development_dependency "dotenv", "~> 0.2"
  gem.add_development_dependency "guard", "~> 1.4"
  gem.add_development_dependency "rspec", "~> 2.11"
  gem.add_development_dependency "rake", "~> 0.9.2"
  gem.add_development_dependency "webmock", "~> 1.8"
  
  gem.add_development_dependency "pry"
end
