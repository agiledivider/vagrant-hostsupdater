require 'open3'

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

        if ip = getAwsPublicIp
          ips.push(ip)
        elsif ip = getGooglePublicIp
          ips.push(ip)
        else
            @machine.config.vm.networks.each do |network|
              key, options = network[0], network[1]
              ip = options[:ip] if (key == :private_network || key == :public_network) && options[:hostsupdater] != "skip"
              ips.push(ip) if ip
              if options[:hostsupdater] == 'skip'
                @ui.info '[vagrant-hostsupdater] Skipping adding host entries (config.vm.network hostsupdater: "skip" is set)'
            end
          end
        end

        if @machine.provider_name == :lxc
          ip = @machine.provider.capability(:public_address)
          ips.push(ip)
        elsif @machine.provider_name == :docker
          ip = @machine.provider.capability(:public_address)
          ips.push(ip)
        elsif @machine.provider_name == :libvirt
          ssh_info = @machine.ssh_info
          if ssh_info
            ips.push(ssh_info[:host])
          end
        end
        if not ips.any?
          ips.push( '127.0.0.1' )
        end
        return ips.uniq
        end

      # Get a hash of hostnames indexed by ip, e.g. { 'ip1': ['host1'], 'ip2': ['host2', 'host3'] }
      def getHostnames(ips)
        hostnames = Hash.new { |h, k| h[k] = [] }

        case @machine.config.hostsupdater.aliases
        when Array
          # simple list of aliases to link to all ips
          ips.each do |ip|
            hostnames[ip] += @machine.config.hostsupdater.aliases
          end
        when Hash
          # complex definition of aliases for various ips
          @machine.config.hostsupdater.aliases.each do |ip, hosts|
            hostnames[ip] += Array(hosts)
          end
        end

        # handle default hostname(s) if not already specified in the aliases
        Array(@machine.config.vm.hostname).each do |host|
          if hostnames.none? { |k, v| v.include?(host) }
            ips.each do |ip|
              hostnames[ip].unshift host
            end
          end
        end

        return hostnames
      end

      def addHostEntries
        ips = getIps
        hostnames = getHostnames(ips)
        file = File.open(@@hosts_path, "rb")
        hostsContents = file.read
        uuid = @machine.id
        name = @machine.name
        entries = []
        ips.each do |ip|
          hostnames[ip].each do |hostname|
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
        %Q(#{ip}  #{hostname}  #{signature(name, uuid.to_s)})
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
        elsif Vagrant::Util::Platform.windows?
          require 'tmpdir'
          uuid = @machine.id || @machine.config.hostsupdater.id
          tmpPath = File.join(Dir.tmpdir, 'hosts-' + uuid.to_s + '.cmd')
          File.open(tmpPath, "w") do |tmpFile|
          entries.each { |line| tmpFile.puts(">>\"#{@@hosts_path}\" echo #{line}") }
          end
          sudo(tmpPath)
          File.delete(tmpPath)
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
        if !File.writable_real?(@@hosts_path) || Vagrant::Util::Platform.windows?
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
          ips = getIps
          hostnames = getHostnames(ips)
          ips.each do |ip|
            hostnames[ip].each do |hostname|
              command = %Q(sed -i -e '/#{hostname}/ d' #@@ssh_known_hosts_path)
              if system(command)
                @ui.info "[vagrant-hostsupdater] Removed host: #{hostname} from ssh_known_hosts file: #@@ssh_known_hosts_path"
              end
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
        if Vagrant::Util::Platform.windows?
          require 'win32ole'
          args = command.split(" ")
          command = args.shift
          sh = WIN32OLE.new('Shell.Application')
          sh.ShellExecute(command, args.join(" "), '', 'runas', 0)
        else
          return system("sudo #{command}")
        end
      end

      def adviseOnSudo
        @ui.error "[vagrant-hostsupdater] Consider adding the following to your sudoers file:"
        @ui.error "[vagrant-hostsupdater]   https://github.com/cogitatio/vagrant-hostsupdater#suppressing-prompts-for-elevating-privileges"
      end

      def getAwsPublicIp
        return nil if ! Vagrant.has_plugin?("vagrant-aws")
        aws_conf = @machine.config.vm.get_provider_config(:aws)
        return nil if ! aws_conf.is_a?(VagrantPlugins::AWS::Config)
        filters = ( aws_conf.tags || [] ).map {|k,v| sprintf('"Name=tag:%s,Values=%s"', k, v) }.join(' ')
        return nil if filters == ''
        cmd = 'aws ec2 describe-instances --filter '+filters
        stdout, stderr, stat = Open3.capture3(cmd)
        @ui.error sprintf("Failed to execute '%s' : %s", cmd, stderr) if stderr != ''
        return nil if stat.exitstatus != 0
        begin
          return JSON.parse(stdout)["Reservations"].first()["Instances"].first()["PublicIpAddress"]
        rescue => e
          @ui.error sprintf("Failed to get IP from the result of '%s' : %s", cmd, e.message)
          return nil
        end
      end

      def getGooglePublicIp
        return nil if ! defined?(VagrantPlugins::Google)
        google_conf = @machine.config.vm.get_provider_config(:google)
        return nil if ! google_conf.is_a?(VagrantPlugins::Google::Config)
        cmd = 'gcloud compute instances list --filter="name=%s" --format="value(networkInterfaces[0].accessConfigs[0].natIP)"'
        cmd = sprintf(cmd, google_conf.name)
        stdout, stderr, stat = Open3.capture3(cmd)
        @ui.error "Failed to execute '#{cmd}' : #{stderr}" if stderr != ''
        ip = stdout.strip
        return nil if stat.exitstatus != 0 || ip == nil || ip == ''
        return ip
      end
    end
  end
end
