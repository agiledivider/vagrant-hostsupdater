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
        

## Passwordless sudo

To allow vagrant to automatically update the hosts file without asking for a sudo password, add the following snippet to a new sudoers file include, i.e. `sudo visudo -f /etc/sudoers.d/vagrant_hostsupdater`:

    # Allow passwordless startup of Vagrant with vagrant-hostsupdater.
    Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c echo "*" >> /etc/hosts
    Cmnd_Alias VAGRANT_HOSTS_REMOVE = /usr/bin/env sed -i -e /*/ d /etc/hosts
    %sudo ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE

Notes:

- For MacOS, change %sudo to %admin on the last line above
- If vagrant still asks for a password on commands that trigger the `VAGRANT_HOSTS_REMOVE` alias above (like
**halt** or **suspend**), this might indicate that the location of **sed** in the `VAGRANT_HOSTS_REMOVE` alias is
pointing to the wrong location. The solution is to find the location of **sed** (ex. `which sed`) and
replace that location in the `VAGRANT_HOSTS_REMOVE` alias. For example, on some newer Ubuntu versions (seen as
early as Ubuntu 14.04 with 4.2.0-30-generic kernel - thanks to austinprey), the command portion of that line
should change from `/usr/bin/sed` to `/bin/sed` like this:

  `Cmnd_Alias VAGRANT_HOSTS_REMOVE = /bin/sed -i -e /*/ d /etc/hosts`

  For MacOS, the location of **sed** is `/usr/bin/sed`, so MacOS users should update the snippet accordingly:

  `Cmnd_Alias VAGRANT_HOSTS_REMOVE = /usr/bin/sed -i -e /*/ d /etc/hosts`

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
