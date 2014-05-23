# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ashikawa-core/version'

Gem::Specification.new do |gem|
  gem.name        = 'ashikawa-core'
  gem.version     = Ashikawa::Core::VERSION
  gem.authors     = ['moonglum']
  gem.email       = ['me@moonglum.net']
  gem.homepage    = 'http://triagens.github.com/ashikawa-core'
  gem.summary     = 'Ashikawa Core is a wrapper around the ArangoDB REST API'
  gem.description = 'Ashikawa Core is a wrapper around the ArangoDB REST API. It provides low level access and is intended to be used in ArangoDB ODMs and other tools.'
  gem.license = 'Apache License 2.0'

  gem.required_ruby_version = '>= 1.9.3'
  gem.requirements << 'ArangoDB, v2.0'

  gem.rubyforge_project = 'ashikawa-core'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  # Runtime Dependencies
  gem.add_dependency 'faraday', '~> 0.9.0'
  gem.add_dependency 'faraday_middleware', '~> 0.9.1'
  gem.add_dependency 'null_logger', '~> 0.0.1'
  gem.add_dependency 'equalizer', '~> 0.0.8'

  # Development Dependencies
  gem.add_development_dependency 'rake', '~> 10.3.2'
  gem.add_development_dependency 'json', '~> 1.8.1'
  gem.add_development_dependency 'rspec', '~> 3.0.0.rc1'
  gem.add_development_dependency 'rspec-its', '~> 1.0.1'
  gem.add_development_dependency 'codeclimate-test-reporter', '~> 0.3.0'
  gem.add_development_dependency 'yard', '~> 0.8.7.4'
  gem.add_development_dependency 'inch', '~> 0.4.6'
  gem.add_development_dependency 'reek', '~> 1.3.7'
  gem.add_development_dependency 'mutant', '~> 0.5.12'
  gem.add_development_dependency 'mutant-rspec', '~> 0.5.14'
  gem.add_development_dependency 'pry', '~> 0.9.12.6'
  gem.add_development_dependency 'guard', '~> 2.6.1'
  gem.add_development_dependency 'guard-rspec', '~> 4.2.9'
  gem.add_development_dependency 'guard-bundler', '~> 2.0.0'

  # Rubinius specific dependencies
  if RUBY_ENGINE == 'rbx'
    gem.add_dependency 'rubysl-base64'
    gem.add_dependency 'rubysl-singleton'
  end
end
