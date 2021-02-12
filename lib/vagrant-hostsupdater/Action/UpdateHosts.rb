module VagrantPlugins
  module HostsUpdater
    module Action
      class UpdateHosts < BaseAction

        def run(env)
          @ui.info "[vagrant-hostsupdater] Checking for host entries"
          addHostEntries()
        end

      end
    end
  end
end
