# Vagrant::Hostsupdater

[![Gem Version](https://badge.fury.io/rb/vagrant-hostsupdater.svg)](https://badge.fury.io/rb/vagrant-hostsupdater)
[![Gem](https://img.shields.io/gem/dt/vagrant-hostsupdater.svg)](https://rubygems.org/gems/vagrant-hostsupdater)
[![Gem](https://img.shields.io/gem/dtv/vagrant-hostsupdater.svg)](https://rubygems.org/gems/vagrant-hostsupdater)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/cogitatio/vagrant-hostsupdater?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/cogitatio/vagrant-hostsupdater.svg?style=social)](https://twitter.com/intent/tweet?text=Checkout%20this%20awesome%20Vagrant%20plugin!&url=https%3A%2F%2Fgithub.com%2Fcogiatio%2Fvagrant-hostsupdater&hashtags=hostsupdater,vagrant)


This plugin adds an entry to your /etc/hosts file on the host system.

On **up**, **resume** and **reload** commands, it tries to add the information, if its not already existant in your hosts file. If it needs to be added, you will be asked for an administrator password, since it uses sudo to edit the file.

On **halt**, **destroy**, and **suspend**, those entries will be removed again.
By setting the remove\_on\_suspend option to `false`, **suspend** will not remove them:

    config.hostsupdater.remove_on_suspend = false

## Skipping hostupdater

To skip adding some entries to the /etc/hosts file add `hostsupdater: "skip"` option to network configuration:

    config.vm.network :private_network, ip: "172.21.9.9", hostsupdater: "skip"

Example:

    config.vm.network :private_network, ip: "192.168.50.4"
    config.vm.network :private_network,
        ip: "172.21.9.9",
        netmask: "255.255.240.0",
        hostsupdater: "skip"

## Installation

    $ vagrant plugin install vagrant-hostsupdater

Uninstall it with:

    $ vagrant plugin uninstall vagrant-hostsupdater

## Usage

You currently only need the `hostname` and a `:private_network` network with a fixed IP address.

    config.vm.network :private_network, ip: "192.168.3.10"
    config.vm.hostname = "www.testing.de"
    config.hostsupdater.aliases = ["alias.testing.de", "alias2.somedomain.com"]

This IP address and the hostname will be used for the entry in the `/etc/hosts` file.

##  Versions

### 1.0.0
* Stable release
* Defaults `remove_on_suspend` to true
* Added `skip` flag
* Hosts update on provision action
* Using Semantic Versioning for version number

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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
