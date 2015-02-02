require_relative "../MultiHostsUpdater"
module VagrantPlugins
  module MultiHostsUpdater
    module Action
      class UpdateHosts
        include MultiHostsUpdater


        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          @ui.info "Checking for host entries with env #{env}"
          @app.call(env)
          puts "about to call addhostentries"
          addHostEntries()
        end

      end
    end
  end
end