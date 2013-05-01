require "vagrant"

module VagrantPlugins
  module HostsUpdater
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :aliases
    end
  end
end