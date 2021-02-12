module VagrantPlugins
  module HostsUpdater
    module Action
      class CacheHosts < BaseAction

        def run(env)
          cacheHostEntries
        end

      end
    end
  end
end
