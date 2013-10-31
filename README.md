# Vagrant::Hostsupdater

This plugin adds an entry to your /etc/hosts file on the host system.

On **up**, **resume** and **reload** commands, it tries to add the information, if its not already existant in your hosts file. If it needs to be added, you will be asked for an administrator password, since it uses sudo to edit the file.

On **halt** and **destroy**, those entries will be removed again.
By setting the remove\_on\_suspend option, you can have them removed on **suspend**, too:

    config.hostsupdater.remove_on_suspend = true



## Installation

    $ vagrant plugin install vagrant-hostsupdater

Uninstall it with:

    $ vagrant plugin uninstall vagrant-hostsupdater

## Usage

At the moment, the only things you need, are the hostname and a :private_network network with a fixed ip.

    config.vm.network :private_network, ip: "192.168.3.10"
    config.vm.hostname = "www.testing.de"
    config.hostsupdater.aliases = ["alias.testing.de", "alias2.somedomain.com"]

This ip and the hostname will be used for the entry in the /etc/hosts file.

##  Versions

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
