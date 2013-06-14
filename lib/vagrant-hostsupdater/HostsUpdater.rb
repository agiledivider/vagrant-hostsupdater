module VagrantPlugins
  module HostsUpdater
    module HostsUpdater
      def test
        puts "jawoll"
      end
  
	  class << self
        def expand_path(relative_path, relative_to)
		  File.expand_path(relative_path, relative_to)
        end

        def hosts_path
          Vagrant::Util::Platform.windows? ? expand_path('system32/drivers/etc/hosts', ENV['windir']) : '/etc/hosts'
        end
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
        file = File.open("#{HostsUpdater::hosts_path}", "rb")
        hostsContents = file.read
        uuid = @machine.id
        name = @machine.name
        entries = []
        ips.each do |ip|
          hostEntries = getHostEntries(ip, hostnames, name, uuid)
          hostEntries.each do |hostEntry|
            escapedEntry = Regexp.quote(hostEntry)
            if !hostsContents.match(/#{escapedEntry}/)
              @ui.info "pushing #{hostEntry}"
              entries.push(hostEntry)
            end
          end
        end
        @ui.info entries
        if !File.writable?("#{HostsUpdater::hosts_path}")
		  sudo(addToHosts(entries))
        else
          command = addToHosts(entries)
          `#{command}`
        end

      end

      def removeHostEntries
        file = File.open("#{HostsUpdater::hosts_path}", "rb")
        hostsContents = file.read
        uuid = @machine.id
        escapedId = Regexp.quote(uuid)
        puts "#{uuid}"
        puts "#{escapedId}"
        if hostsContents.match(/#{escapedId}/)
            puts "removing uids"
            puts "#{removeFromHosts}"
            if !File.writable?("#{HostsUpdater::hosts_path}")
			  sudo(removeFromHosts)
            else
			  command = removeFromHosts
			  if !Vagrant::Util::Platform.windows?
               `#{command}`
              end
			end
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
        #hosts_path = "/etc/hosts"
        content = entries.join("\n")
        %Q(sh -c 'echo "#{content}" >>#{HostsUpdater::hosts_path}')
      end

      def removeFromHosts(options = {})
        #hosts_path = "/etc/hosts"
        uuid = @machine.id
		if Vagrant::Util::Platform.windows?
			# find and replace isn't going to work here as in the unix environment (no sed like application)
			hosts = ""
			FileUtils.copy HostsUpdater::hosts_path, "#{HostsUpdater::hosts_path}.bak"
			File.open("#{HostsUpdater::hosts_path}").each do |line|
			  hosts << line unless line.include?(uuid)
			end
			File.open("#{HostsUpdater::hosts_path}", "w") {|file| file.puts hosts }
			""
		else
		  %Q(sed -e '/#{uuid}$/ d' -ibak #{HostsUpdater::hosts_path})
		end
      end



      def signature(name, uuid = self.uuid)
        %Q(# VAGRANT: #{uuid} (#{name}))
      end

      def sudo(command)
        return if !command
        if Vagrant::Util::Platform.windows?
		  @ui.info command
           `#{command}`
        else
          `sudo #{command}`
        end
      end
    end
  end
end