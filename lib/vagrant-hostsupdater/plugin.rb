

module VagrantPlugins
  module HostsUpdater
    class Plugin < Vagrant.plugin('2')
      name 'HostsUpdater'
      description <<-DESC
        This plugin manages the /etc/hosts file for the host machine. An entry is
        created for the hostname attribute in the vm.config.
      DESC

      config(:hostsupdater) do
        require_relative 'config'
        Config
      end

      # action_hook(:hostmanager, :machine_action_up) do |hook|
      #   hook.prepend(Action::UpdateHosts)
      # end

      # action_hook(:hostmanager, :machine_action_halt) do |hook|
      #   hook.append(Action::UpdateHosts)
      # end

      # action_hook(:hostmanager, :machine_action_suspend) do |hook|
      #   hook.append(Action::UpdateHosts)
      # end

      # action_hook(:hostmanager, :machine_action_destroy) do |hook|
      #   hook.append(Action::UpdateHosts)
      # end

      command(:hostsupdater) do
        require_relative 'command'
        Command
      end
    end
  end
end