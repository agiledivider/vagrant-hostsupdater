# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-hostsupdater/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-hostsupdater'
  spec.version       = VagrantPlugins::HostsUpdater::VERSION
  spec.authors       = ['Falk Kühnel', 'Chris Smith']
  spec.email         = ['fk@cogitatio.de', 'chris@cgsmith.net']
  spec.description   = %q{Enables Vagrant to update hosts file on the host machine}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/cogitatio/vagrant-hostsupdater'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
