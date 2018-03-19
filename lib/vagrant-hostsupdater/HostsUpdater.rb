module VagrantPlugins
  module HostsUpdater
    module HostsUpdater
      if ENV['VAGRANT_HOSTSUPDATER_PATH']
        @@hosts_path = ENV['VAGRANT_HOSTSUPDATER_PATH']
      else
        @@hosts_path = Vagrant::Util::Platform.windows? ? File.expand_path('system32/drivers/etc/hosts', ENV['windir']) : '/etc/hosts'
      end
      @isWindowsHost = Vagrant::Util::Platform.windows?
      @@ssh_known_hosts_path = '~/.ssh/known_hosts'

      def getIps
        ips = []
        @machine.config.vm.networks.each do |network|
          key, options = network[0], network[1]
          ip = options[:ip] if (key == :private_network || key == :public_network) && options[:hostsupdater] != "skip"
          ips.push(ip) if ip
          if options[:hostsupdater] == 'skip'
            @ui.info '[vagrant-hostsupdater] Skipping adding host entries (config.vm.network hostsupdater: "skip" is set)'
          end
        end

        if @machine.provider_name == :lxc
          ip = @machine.provider.capability(:public_address)
          ips.push(ip)
        elsif @machine.provider_name == :docker
          ip = @machine.provider.capability(:public_address)
          ips.push(ip)
        end

        return ips
      end

      def getHostnames
        hostnames = Array(@machine.config.vm.hostname)
        if @machine.config.hostsupdater.aliases
          hostnames.concat(@machine.config.hostsupdater.aliases)
        end
        return hostnames
      end

      def addHostEntries()
        ips = getIps
        hostnames = getHostnames
        file = File.open(@@hosts_path, "rb")
        hostsContents = file.read
        uuid = @machine.id
        name = @machine.name
        entries = []
        ips.each do |ip|
          hostnames.each do |hostname|
            entryPattern = hostEntryPattern(ip, hostname)

            if hostsContents.match(/#{entryPattern}/)
              @ui.info "[vagrant-hostsupdater]   found entry for: #{ip} #{hostname}"
            else
              hostEntry = createHostEntry(ip, hostname, name, uuid)
              entries.push(hostEntry)
            end
          end
        end
        addToHosts(entries)
      end

      def cacheHostEntries
        @machine.config.hostsupdater.id = @machine.id
      end

      def removeHostEntries
        if !@machine.id and !@machine.config.hostsupdater.id
          @ui.info "[vagrant-hostsupdater] No machine id, nothing removed from #@@hosts_path"
          return
        end
        file = File.open(@@hosts_path, "rb")
        hostsContents = file.read
        uuid = @machine.id || @machine.config.hostsupdater.id
        hashedId = Digest::MD5.hexdigest(uuid)
        if hostsContents.match(/#{hashedId}/)
          removeFromHosts
          removeFromSshKnownHosts
        end
      end

      def host_entry(ip, hostnames, name, uuid = self.uuid)
        %Q(#{ip}  #{hostnames.join(' ')}  #{signature(name, uuid)})
      end

      def createHostEntry(ip, hostname, name, uuid = self.uuid)
        %Q(#{ip}  #{hostname}  #{signature(name, uuid)})
      end

      # Create a regular expression that will match *any* entry describing the
      # given IP/hostname pair. This is intentionally generic in order to
      # recognize entries created by the end user.
      def hostEntryPattern(ip, hostname)
        Regexp.new('^\s*' + ip + '\s+' + hostname + '\s*(#.*)?$')
      end

      def addToHosts(entries)
        return if entries.length == 0
        content = entries.join("\n").strip

        @ui.info "[vagrant-hostsupdater] Writing the following entries to (#@@hosts_path)"
        @ui.info "[vagrant-hostsupdater]   " + entries.join("\n[vagrant-hostsupdater]   ")
        if !File.writable_real?(@@hosts_path)
          @ui.info "[vagrant-hostsupdater] This operation requires administrative access. You may " +
                       "skip it by manually adding equivalent entries to the hosts file."
          if !sudo(%Q(sh -c 'echo "#{content}" >> #@@hosts_path'))
            @ui.error "[vagrant-hostsupdater] Failed to add hosts, could not use sudo"
            adviseOnSudo
          end
        else
          content = "\n" + content + "\n"
          hostsFile = File.open(@@hosts_path, "a")
          hostsFile.write(content)
          hostsFile.close()
        end
      end

      def removeFromHosts(options = {})
        uuid = @machine.id || @machine.config.hostsupdater.id
        hashedId = Digest::MD5.hexdigest(uuid)
        if !File.writable_real?(@@hosts_path)
          if !sudo(%Q(sed -i -e '/#{hashedId}/ d' #@@hosts_path))
            @ui.error "[vagrant-hostsupdater] Failed to remove hosts, could not use sudo"
            adviseOnSudo
          end
        else
          hosts = ""
          File.open(@@hosts_path).each do |line|
            hosts << line unless line.include?(hashedId)
          end
          hosts.strip!
          hostsFile = File.open(@@hosts_path, "w")
          hostsFile.write(hosts)
          hostsFile.close()
        end
      end

      def removeFromSshKnownHosts
        if !@isWindowsHost
          hostnames = getHostnames
          hostnames.each do |hostname|
            command = %Q(sed -i -e '/#{hostname}/ d' #@@ssh_known_hosts_path)
            if system(command)
              @ui.info "[vagrant-hostsupdater] Removed host: #{hostname} from ssh_known_hosts file: #@@ssh_known_hosts_path"
            end
          end
        end
      end

      def signature(name, uuid = self.uuid)
        hashedId = Digest::MD5.hexdigest(uuid)
        %Q(# VAGRANT: #{hashedId} (#{name}) / #{uuid})
      end

      def sudo(command)
        return if !command
        if @isWindowsHost
          `#{command}`
        else
          return system("sudo #{command}")
        end
      end

      def adviseOnSudo
        @ui.error "[vagrant-hostsupdater] Consider adding the following to your sudoers file:"
        @ui.error "[vagrant-hostsupdater]   https://github.com/cogitatio/vagrant-hostsupdater#passwordless-sudo"
      end
    end
  end
end
