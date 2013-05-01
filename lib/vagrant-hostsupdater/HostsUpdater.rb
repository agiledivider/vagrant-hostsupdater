module VagrantPlugins
  module HostsUpdater
    module HostsUpdater
      def test
        puts "jawoll"
      end

      def getIps
        ips = []
        @machine.config.vm.networks.each do |network|
          key, options = network[0], network[1]
          ip = options[:ip] if key == :private_network
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
        file = File.open("/etc/hosts", "rb")
        hostsContents = file.read
        uuid = @machine.id
        name = @machine.name
        entries = []
        ips.each do |ip|
          hostEntries = getHostEntries(ip, hostnames, name, uuid)
          hostEntries.each do |hostEntry|
            escapedEntry = Regexp.quote(hostEntry)
            if !hostsContents.match(/#{escapedEntry}/)
              entries.push(hostEntry)
            end
          end
        end
        sudo(addToHosts(entries))

      end

      def removeHostEntries
        file = File.open("/etc/hosts", "rb")
        hostsContents = file.read
        uuid = @machine.id
        escapedId = Regexp.quote(uuid)
        puts "#{uuid}"
        puts "#{escapedId}"
        if hostsContents.match(/#{escapedId}/)
            puts "removing uids"
            puts "#{removeFromHosts}"
            sudo(removeFromHosts)
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
        hosts_path = '/etc/hosts'
        content = entries.join("\n")
        %Q(sh -c 'echo "#{content}" >>#{hosts_path}')
      end

      def removeFromHosts(options = {})
        hosts_path = '/etc/hosts'
        uuid = @machine.id
        %Q(sed -e '/#{uuid}/ d' -ibak #{hosts_path})
      end



      def signature(name, uuid = self.uuid)
        %Q(# VAGRANT: #{uuid} (#{name}))
      end

      def sudo(command)
        return if !command
        # if Util::Platform.windows?
        #   `#{command}`
        # else
          `sudo #{command}`
        # end
      end
    end
  end
end