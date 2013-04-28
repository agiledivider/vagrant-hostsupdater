module VagrantPlugins
  module HostUpdater
    module Action
      class UpdateHostsFile
        #include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          # @logger = Log4r::Logger.new('vagrant::hostupdater::update_hosts_file')
        end

        def call(env)
          @loger.info "Updating"
          # # check if machine is already active
          # return @app.call(env) if @machine.id

          # # check config to see if the hosts file should be update automatically
          # return @app.call(env) unless @machine.config.hostmanager.enabled?
          # @logger.info 'Updating /etc/hosts file automatically'

          # # continue the action stack so the machine will be created
          # @app.call(env)

          # # update /etc/hosts file on each active machine
          # machines = generate(@machine.env, @machine.provider_name)
          # machines.each { |machine| update(machine) }
        end
      end
    end
  end
end