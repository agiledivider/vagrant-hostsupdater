module VagrantPlugins
  module HostsUpdater
    module Action
      class CacheHosts
        include HostsUpdater

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
        end

        def call(env)
          cacheHostEntries
          @app.call(env)
        end

      end
    end
  end
end
