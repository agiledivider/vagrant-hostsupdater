module VagrantPlugins
  module HostsUpdater
    module HostsUpdater
      @@hosts_path = Vagrant::Util::Platform.windows? ? File.expand_path('system32/drivers/etc/hosts', ENV['windir']) : '/etc/hosts'

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
        @ui.info "[vagrant-hostsupdater] This operation requires administrative access. You may " +
          "skip it by manually adding equivalent entries to the hosts file."
        if !File.writable_real?(@@hosts_path)
          if !sudo(%Q(sh -c 'echo "#{content}" >> #@@hosts_path'))
            @ui.error "[vagrant-hostsupdater] Failed to add hosts, could not use sudo"
            adviseOnSudo
          end
        else
          content = "\n" + content
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
          hostsFile = File.open(@@hosts_path, "w")
          hostsFile.write(hosts)
          hostsFile.close()
        end
      end



      def signature(name, uuid = self.uuid)
        hashedId = Digest::MD5.hexdigest(uuid)
        %Q(# VAGRANT: #{hashedId} (#{name}) / #{uuid})
      end

      def sudo(command)
        return if !command
        if Vagrant::Util::Platform.windows?
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
