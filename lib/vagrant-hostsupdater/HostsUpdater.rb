module VagrantPlugins
  module HostsUpdater
    module HostsUpdater
      @@hosts_path = Vagrant::Util::Platform.windows? ? File.expand_path('system32/drivers/etc/hosts', ENV['windir']) : '/etc/hosts'

      def getIps
        ips = []
        @machine.config.vm.networks.each do |network|
          key, options = network[0], network[1]
          ip = options[:ip] if key == :private_network && options[:hostsupdater] != "skip"
          ips.push(ip) if ip
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
          hostEntries = getHostEntries(ip, hostnames, name, uuid)
          hostEntries.each do |hostEntry|
            escapedEntry = Regexp.quote(hostEntry)
            if !hostsContents.match(/#{escapedEntry}/)
              @ui.info "adding to (#@@hosts_path) : #{hostEntry}"
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
          @ui.warn "No machine id, nothing removed from #@@hosts_path"
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

      def getHostEntries(ip, hostnames, name, uuid = self.uuid)
        entries = []
        hostnames.each do |hostname|
          entries.push(%Q(#{ip}  #{hostname}  #{signature(name, uuid)}))
        end
        return entries
      end

      def addToHosts(entries)
        return if entries.length == 0
        content = entries.join("\n").strip.concat("\n")
        if !File.writable?(@@hosts_path)
          sudo(%Q(sh -c 'echo "#{content}" >> #@@hosts_path'))
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
        if !File.writable?(@@hosts_path)
          sudo(%Q(sed -i -e '/#{hashedId}/ d' #@@hosts_path))
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
          `sudo #{command}`
        end
      end
    end
  end
end
