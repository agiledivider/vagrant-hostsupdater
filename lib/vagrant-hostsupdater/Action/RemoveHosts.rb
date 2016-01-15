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
          if machine_action != :destroy || !@machine.id
            if machine_action != :suspend || false != @machine.config.hostsupdater.remove_on_suspend
              if machine_action != :halt || false != @machine.config.hostsupdater.remove_on_suspend
                @ui.info "[vagrant-hostsupdater] Removing hosts"
                removeHostEntries
              else
                @ui.info "[vagrant-hostsupdater] Removing hosts on suspend disabled"
              end
            end
          end
          @app.call(env)
        end

      end
    end
  end
end
