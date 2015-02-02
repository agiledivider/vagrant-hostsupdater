require "vagrant-multi-hostsupdater/version"
require "vagrant-multi-hostsupdater/plugin"

module VagrantPlugins
  module MultiHostsUpdater
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end

