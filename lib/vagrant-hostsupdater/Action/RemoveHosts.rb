module VagrantPlugins
  module HostsUpdater
    module Action
      class RemoveHosts
        include HostsUpdater

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          @ui.info "Removing hosts"
          @app.call(env)
          removeHostEntries
        end

      end
    end
  end
end