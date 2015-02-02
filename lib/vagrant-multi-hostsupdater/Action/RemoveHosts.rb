module VagrantPlugins
  module MultiHostsUpdater
    module Action
      class RemoveHosts
        include MultiHostsUpdater

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          machine_action = env[:machine_action]
          if machine_action != :destroy || !@machine.id
            if machine_action != :suspend || @machine.config.multihostsupdater.remove_on_suspend
              @ui.info "Removing hosts"
              removeHostEntries
            else
              @ui.info "Removing hosts on suspend disabled"
            end
          end
          @app.call(env)
        end

      end
    end
  end
end
