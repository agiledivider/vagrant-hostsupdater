# Vagrant::Hostsupdater

[![Gem Version](https://badge.fury.io/rb/vagrant-hostsupdater.svg)](https://badge.fury.io/rb/vagrant-hostsupdater)
[![Gem](https://img.shields.io/gem/dt/vagrant-hostsupdater.svg)](https://rubygems.org/gems/vagrant-hostsupdater)
[![Gem](https://img.shields.io/gem/dtv/vagrant-hostsupdater.svg)](https://rubygems.org/gems/vagrant-hostsupdater)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/cogitatio/vagrant-hostsupdater?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/cogitatio/vagrant-hostsupdater.svg?style=social)](https://twitter.com/intent/tweet?text=Checkout%20this%20awesome%20Vagrant%20plugin!&url=https%3A%2F%2Fgithub.com%2Fcogiatio%2Fvagrant-hostsupdater&hashtags=hostsupdater,vagrant)


This plugin adds an entry to your /etc/hosts file on the host system.

On **up**, **resume** and **reload** commands, it tries to add the information, if it does not already exist in your hosts file. If it needs to be added, you will be asked for an administrator password, since it uses sudo to edit the file.

On **halt**, **destroy**, and **suspend**, those entries will be removed again.
By setting the `config.hostsupdater.remove_on_suspend  = false`, **suspend** and **halt** will not remove them. 


## Installation

    $ vagrant plugin install vagrant-hostsupdater

Uninstall it with:

    $ vagrant plugin uninstall vagrant-hostsupdater

Update the plugin with:

    $ vagrant plugin update vagrant-hostsupdater

## Usage

You currently only need the `hostname` and a `:private_network` network with a fixed IP address.

    config.vm.network :private_network, ip: "192.168.3.10"
    config.vm.hostname = "www.testing.de"
    config.hostsupdater.aliases = ["alias.testing.de", "alias2.somedomain.com"]

This IP address and the hostname will be used for the entry in the `/etc/hosts` file.

### Multiple private network adapters

If you have multiple network adapters i.e.:

    config.vm.network :private_network, ip: "10.0.0.1"
    config.vm.network :private_network, ip: "10.0.0.2"

you can specify which hostnames are bound to which IP by passing a hash mapping the IP of the network to an array of hostnames to create, e.g.:

    config.hostsupdater.aliases = {
        '10.0.0.1' => ['foo.com', 'bar.com'],
        '10.0.0.2' => ['baz.com', 'bat.com']
    }

This will produce `/etc/hosts` entries like so:

    10.0.0.1 foo.com
    10.0.0.1 bar.com
    10.0.0.2 baz.com
    10.0.0.2 bat.com

### Skipping hostupdater

To skip adding some entries to the /etc/hosts file add `hostsupdater: "skip"` option to network configuration:

    config.vm.network "private_network", ip: "172.21.9.9", hostsupdater: "skip"

Example:

    config.vm.network :private_network, ip: "192.168.50.4"
    config.vm.network :private_network,
        ip: "172.21.9.9",
        netmask: "255.255.240.0",
        hostsupdater: "skip"
        
### Keeping Host Entries After Suspend/Halt

To keep your /etc/hosts file unchanged simply add the line below to your `VagrantFile`:

    config.hostsupdater.remove_on_suspend = false
    
This disables vagrant-hostsupdater from running on **suspend** and **halt**.
        

## Suppressing prompts for elevating privileges

These prompts exist to prevent anything that is being run by the user from inadvertently updating the hosts file. 
If you understand the risks that go with supressing them, here's how to do it.

### Linux/OS X: Passwordless sudo

To allow vagrant to automatically update the hosts file without asking for a sudo password, add one of the following snippets to a new sudoers file include, i.e. `sudo visudo -f /etc/sudoers.d/vagrant_hostsupdater`.

For Ubuntu and most Linux environments:

    # Allow passwordless startup of Vagrant with vagrant-hostsupdater.
    Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c echo "*" >> /etc/hosts
    Cmnd_Alias VAGRANT_HOSTS_REMOVE = /bin/sed -i -e /*/ d /etc/hosts
    %sudo ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE

For MacOS:

    # Allow passwordless startup of Vagrant with vagrant-hostsupdater.
    Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c echo "*" >> /etc/hosts
    Cmnd_Alias VAGRANT_HOSTS_REMOVE = /usr/bin/sed -i -e /*/ d /etc/hosts
    %admin ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE
    
- If vagrant still asks for a password on commands that trigger the `VAGRANT_HOSTS_ADD` alias above (like **up**), you might need to wrap the echo statement in quotes, i.e. `Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c 'echo "*" >> /etc/hosts'`. This seems to be a problem with older versions of Linux and MacOS.
- If vagrant still asks for a password on commands that trigger the `VAGRANT_HOSTS_REMOVE` alias above (like
**halt** or **suspend**), this might indicate that the location of **sed** in the `VAGRANT_HOSTS_REMOVE` alias is
pointing to the wrong location. The solution is to find the location of **sed** (ex. `which sed`) and
replace that location in the `VAGRANT_HOSTS_REMOVE` alias.
    
### Windows: UAC Prompt

You can use `cacls` or `icacls` to grant your user account permanent write permission to the system's hosts file. 
You have to open an elevated command prompt; hold `❖ Win` and press `X`, then choose "Command Prompt (Admin)"

    cacls %SYSTEMROOT%\system32\drivers\etc\hosts /E /G %USERNAME%:W 

## Using AWS as a Provider

If you'd like AWS as a provider using [vagrant-aws](https://github.com/mitchellh/vagrant-aws) or other plugin,
this plugin will detect the instance public IP by the tag infomations.  
For example, [vagrant-aws](https://github.com/mitchellh/vagrant-aws) configures a tag infomations like the following.

    config.vm.provider :aws do |aws, override|
      aws.tags = {
        "Name" => "vagrant",
        ...
      }
      aws.elastic_ip = true
      ...
    end

* [AWS CLI](https://aws.amazon.com/cli/) is required
* The tag informations be unique for the instance
* Enable Elastic IP for the instance

## Using Google as a provider

If you'd like a Google provider using [vagrant-google](https://github.com/mitchellh/vagrant-google), this plugin will detect the public IP from the name of the instance.
[vagrant-google](https://github.com/mitchellh/vagrant-google) provides a default name, but you can specify your own as follows:

    config.vm.provider :google do |google, override|
      google.name = "somename"
      ...
    end

* [Google Cloud SDK](https://cloud.google.com/sdk/) is required.

## Installing development version

If you would like to install vagrant-hostsupdater on the development version perform the following:

```
git clone https://github.com/cogitatio/vagrant-hostsupdater
cd vagrant-hostsupdater
git checkout develop
gem build vagrant-hostsupdater.gemspec
vagrant plugin install vagrant-hostsupdater-*.gem
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request on the `develop` branch


## Versions

### 1.2.0
* Bugfix: Fixing null string [#188](/../../issues/188)

### 1.1.1
* Bugfix: AWS Feature broke part of the code [#155](/../../issues/155)

### 1.1.0
* Feature: Added AWS support [#74](/../../pull/74)
* Feature: Added libvirt provider [#122](/../../pull/122)
* Feature: Add support for multiple private network adapters [#96](/../../pull/96)
* Feature: Add support for VMs without private/public networking [#23](/../../issues/23)
* Feature: Add Docker support [#149](/../../pull/149)
* Bugfix: Windows users get UAC prompt [#40](/../../issues/40)
* Bugfix: Documentation update and type fix
* Misc: Added a note about suppressing UAC prompts

### 1.0.2
* Feature: Added `remove_on_suspend` for `vagrant_halt` [#71](/../../issues/71)
* Feature: Skip entries if they already exist [#69](/../../issues/69)
* Bugfix: Fixing extra lines in /etc/hosts file [#87](/../../pull/87)
* Misc: Fix yellow text on UI [#39](/../../issues/39)

### 1.0.1
* Bugfix: Fixing `up` issue on initialize [#28](/../../issues/28)

### 1.0.0
* Stable release
* Feature: Added `skip` flag [#69](/../../issues/69)
* Feature: Hosts update on provision action [#65](/../../issues/65)
* Bugfix: `remove_on_suspend` should be true [#19](/../../issues/19)
* Bugfix: Line break not inserted before first host [#37](/../../issues/37)
* Bugfix: Old changes not removed in linux [#67](/../../issues/67)
* Bugfix: Writable issue on OSX [#47](/../../issues/47)
* Bugfix: Update hosts before provisioning [#31](/../../issues/31)
* Misc: Using Semantic Versioning for version number
* Misc: Added note regarding sudoers file

### 0.0.11
* bugfix: Fix additional new lines being added to hosts file (Thanks to vincentmac)

### 0.0.10
* bugfix: wrong path on Windows systems (Thanks to Im0rtality)

### 0.0.9
* bugfix: now not trying to remove anything if no machine id is given

### 0.0.8
* trying to use proper windows hosts file

### 0.0.7
* using hashed uids now to identify hosts entries (you might need to remove previous hostentries manually)
* fixed removing of host entries

### 0.0.6
* no sudo, if /etc/hosts is writeable

### 0.0.5
* option added to not remove hosts on suspend, adding hosts on resume (Thanks to Svelix)

### 0.0.4
* fixed problem with removing hosts entries on destroy command (Thanks to Andy Bohne)

### 0.0.3
* added aliases config option to define additional hostnames
