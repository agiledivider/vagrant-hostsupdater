# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-multi-hostsupdater/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-multi-hostsupdater"
  spec.version       = VagrantPlugins::MultiHostsUpdater::VERSION
  spec.authors       = ["Matt Fellows"]
  spec.email         = ["matt.fellows@onegeek.com.au"]
  spec.description   = %q{Enables Vagrant to update hosts file on the host machine}
  spec.summary       = %q{Enables Vagrant to update hosts file on the host machine}
  spec.homepage      = "https://github.com/SEEK-Jobs/vagrant-hostsupdater"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
