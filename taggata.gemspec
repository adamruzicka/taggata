# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'taggata/version'

Gem::Specification.new do |spec|
  spec.name          = 'taggata'
  spec.version       = Taggata::VERSION
  spec.authors       = ['Adam Ruzicka']
  spec.email         = ['a.ruzicka@outlook.com']
  spec.summary       = 'Gem for scanning the filesystem and storing it in sqlite database with tagging'
  # spec.summary       = %q{TODO: Write a short summary. Required.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = 'https://github.com/adamruzicka/taggata'
  spec.license       = 'BSD-2-Clause'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'sequel', '~> 4.22.0', '>= 4.22.0'
  spec.add_dependency 'sqlite3', '~> 1.3.10', '>= 1.3.10'
  spec.add_dependency 'clamp', '~>1.0.0', '>= 1.0.0'

  spec.add_development_dependency 'thor', '~> 0.0', '>= 0.0.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.6.1', '>= 5.6.1'
  spec.add_development_dependency 'minitest-reporters', '~> 1.0.16', '>= 1.0.16'
  spec.add_development_dependency 'pry', '~> 0.0', '>= 0.0.0'
  spec.add_development_dependency 'mocha', '~> 1.1', '>= 1.1.0'
  spec.add_development_dependency 'rubocop'
end
