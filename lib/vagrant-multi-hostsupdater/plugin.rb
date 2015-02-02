require "vagrant-multi-hostsupdater/Action/UpdateHosts"
require "vagrant-multi-hostsupdater/Action/CacheHosts"
require "vagrant-multi-hostsupdater/Action/RemoveHosts"

module VagrantPlugins
  module MultiHostsUpdater
    class Plugin < Vagrant.plugin('2')
      name 'MultiHostsUpdater'
      description <<-DESC
        This plugin manages the /etc/hosts file for the host machine. An entry is
        created for the hostname attribute in the vm.config.
      DESC

      config(:multihostsupdater) do
        require_relative 'config'
        Config
      end

      action_hook(:multihostsupdater, :machine_action_up) do |hook|
        hook.append(Action::UpdateHosts)
      end

      action_hook(:multihostsupdater, :machine_action_halt) do |hook|
        hook.append(Action::RemoveHosts)
      end

      action_hook(:multihostsupdater, :machine_action_suspend) do |hook|
        hook.append(Action::RemoveHosts)
      end

      action_hook(:multihostsupdater, :machine_action_destroy) do |hook|
        hook.prepend(Action::CacheHosts)
      end

      action_hook(:multihostsupdater, :machine_action_destroy) do |hook|
        hook.append(Action::RemoveHosts)
      end

      action_hook(:multihostsupdater, :machine_action_reload) do |hook|
        hook.append(Action::UpdateHosts)
      end

      action_hook(:multihostsupdater, :machine_action_resume) do |hook|
        hook.append(Action::UpdateHosts)
      end

      command(:multihostsupdater) do
        require_relative 'command'
        Command
      end
    end
  end
end
