module VagrantPlugins
  module HostsUpdater
    module Action
      class RemoveHosts

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          @ui.info "Updating"

        end



      end
    end
  end
end