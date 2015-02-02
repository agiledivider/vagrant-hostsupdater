require "vagrant"

module VagrantPlugins
  module MultiHostsUpdater
    class Config < Vagrant.plugin("2", :config)

        # Array of hostnames to add or a Map[String => Array] of IPs to hostnames.
        #
        # Array syntax: aliases = ['foo.com', 'bar.com']
        # Map syntax:   aliases = {'10.0.0.1' => ['foo.com', 'bar.com'], '10.0.0.2' => ['baz.com', 'bat.com']}
        attr_accessor :aliases
        attr_accessor :id
        attr_accessor :remove_on_suspend
    end
  end
end
