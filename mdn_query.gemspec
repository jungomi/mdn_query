# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mdn_query/version'

Gem::Specification.new do |spec|
  spec.name          = 'mdn_query'
  spec.version       = MdnQuery::VERSION
  spec.authors       = ['Michael Jungo']
  spec.email         = ['michaeljungo92@gmail.com']

  spec.summary       = 'Query the MDN docs'
  spec.description   = 'Query the MDN docs'
  spec.homepage      = 'https://github.com/jungomi/mdn_query'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'launchy', '~> 2.4'
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'rest-client', '~> 1.8'
  spec.add_dependency 'slop', '~> 4.4'
  spec.add_dependency 'tty-pager', '~> 0.4'
  spec.add_dependency 'tty-prompt', '~> 0.7'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 11.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1'
  spec.add_development_dependency 'rubocop', '~> 0.43'
  spec.add_development_dependency 'simplecov', '~> 0.12'
end
