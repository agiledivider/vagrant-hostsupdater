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
          machine_action = env[:machine_action]
          if machine_action != :suspend || @machine.config.hostsupdater.remove_on_suspend
            @ui.info "Removing hosts"
            removeHostEntries
          else
            @ui.info "Removing on suspend disabled"
          end
          @app.call(env)
        end

      end
    end
  end
end
