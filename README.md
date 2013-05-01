# Vagrant::Hostsupdater

This plugin adds an entry to your /etc/hosts file on the host system.

On **up** and **reload** commands, it tries to add the information, if its not already existant in your hosts file. If it needs to be added, you will be asked for an administrator password, since it uses sudo to edit the file.

On **halt**, **suspend** and **destroy**, those entries will be removed again.

## Installation

    $ vagrant install vagrant-hostsupdater

Uninstall it with:

    $ vagrant uninstall vagrant-hostsupdater

## Usage

At the moment, the only things you need, are the hostname and a :private_network network with a fixed ip.

	$ config.vm.network :private_network, ip: "192.168.3.10"
 	$ config.vm.hostname = "www.testing.de"

This ip and the hostname will be used for the entry in the /etc/hosts file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
