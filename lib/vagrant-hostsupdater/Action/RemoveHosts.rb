module VagrantPlugins
  module HostsUpdater
    module Action
      class RemoveHosts < BaseAction

        def run(env)
          machine_action = env[:machine_action]
          if [:suspend, :halt].include? machine_action
            if @machine.config.hostsupdater.remove_on_suspend == false
              @ui.info "[vagrant-hostsupdater] Not removing hosts (remove_on_suspend false)"
            else
              @ui.info "[vagrant-hostsupdater] Removing hosts on suspend"
              removeHostEntries
            end
          else
            @ui.info "[vagrant-hostsupdater] Removing hosts"
            removeHostEntries
          end
        end

      end
    end
  end
end
