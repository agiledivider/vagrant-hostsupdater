require "vagrant-hostsupdater/version"
require "vagrant-hostsupdater/plugin"

module VagrantPlugins
  module HostsUpdater
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end

