# Vagrant::MultiHostsUpdater

This plugin adds an entry to your `/etc/hosts` file on the host system.

On **up**, **resume** and **reload** commands, it tries to add the information, if it doesn't exist in your hosts file. If it needs to be added, you may be asked for an administrator password, as it requires root privileges to modify it.

On **halt** and **destroy**, those entries will be removed again.

## Installation

    $ vagrant plugin install vagrant-multi-hostsupdater

Uninstall it with:

    $ vagrant plugin uninstall vagrant-multi-hostsupdater

## Usage

At the moment, the only things you need, are the hostname and a :private_network network with a fixed ip.

    config.vm.network :private_network, ip: "192.168.3.10"
    config.vm.hostname = "www.testing.de"
    config.multihostsupdater.aliases = ["alias.testing.de", "alias2.somedomain.com"]

### Multiple private network adapters

If you have multiple network adapters you can specify which hostnames are bound to which IP by passing a `Map[String]Array` mapping the IP of the network to an array of hostnames to create. eg:

    config.vm.multihostsupdater.aliases = {'10.0.0.1' => ['foo.com', 'bar.com'], '10.0.0.2' => ['baz.com', 'bat.com']}

This will produce host entries like so:

    10.0.0.1 foo.com
    10.0.0.2 bar.com

### Remove on a `vagrant suspend`

By setting the `remove_on_suspend` option, you can have them removed on **suspend**, too:

    config.multihostsupdater.remove_on_suspend = true


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
