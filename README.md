# Windows DNS Cookbook

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

The custom resources in this cookbook implement the _mechanism_ for configuring both both the DNS client-server and server-suffix on Windows.  For an example of a _policy_ for how to configure DNS, see the se-win-baseline cookbook.

## Requirements

### Chef

Version 2.0.0+ of this cookbook requires Chef 13+

### Platforms

Supported Platform Families:

* Windows

Platforms validated via Test Kitchen:

* Windows 10
* Windows Server 2016

Notes:

* Only Windows 2016 is fully tested.
* Custom resources typically use raw PowerShell scripts for converge and idempotence.  Most recipes therefore should support older versions of Windows, but these are not tested.
* Cookbook dependencies are handled via Berkshelf and are verified only to be compatible with Windows 2016/10.

## Resources

This cookbook provides two resources for configuring DNS in Windows using Powershell.  See [Set-DnsClientServerAddress](https://technet.microsoft.com/en-us/itpro/powershell/windows/dnsclient/set-dnsclientserveraddress) for details on managing static DNS in Windows.  See [Set-DnsClient](https://technet.microsoft.com/en-us/itpro/powershell/windows/dnsclient/set-dnsclient) for details on managing DNS name on Windows.

### dns_client
A dns_client provides a single action to configure static DNS settings for a network interface.

__Actions__
One action is provided.

* `set_server_ips` - Post condition is that the named interface uses the assigned name servers for DNS lookup.

__Attributes__
This resource has four attributes.

* `name` - The `name_property` of the resource.  Must be unique but otherwise ignored.
* `interface_name` - Defaults to `ethernet`.  The alias for the interfaces to be configured, not case sensitive.
* `use_regex_for_interface` - Default to `true`.  Determines if the `interface_name` is used as a regex.  If true, all interfaces for which the the alias regex matches are configured.
* `name_servers` - An array of server IPs as strings.

### dns_suffix
This resource provides a single action to configure the DNS suffix for a network interface.

__Actions__
One action is provided.

* `set_suffix` - Post condition is that the named interface is configured to use the given suffix.

__Attributes__
This resource has five attributes.

* `name` - The `name_property` of the resource.  Must be unique but otherwise ignored.
* `interface_name` - Defaults to `ethernet`.  The alias for the interfaces to be configured, not case sensitive.
* `use_regex_for_interface` - Default to `true`.  Determines if the `interface_name` is used as a regex.  If true, all interfaces for which the the alias regex matches are configured.
* `suffix` - The DNS suffix for this node, that will be concatenated to form a fully qualified domain name, e.g. 'alaska.edu'.
* `register` - Default to `true`.  Determines if this node is registered for DNS lookup.

## Recipes

This is a resource-only cookbook; and adding the default recipe to a node's runlist will have no effect.

## Examples

```ruby
dns_client 'Configure Static DNS' do
  interface_name 'ethernet'
  use_regex_for_interface true
  name_servers ['137.229.15.5', '137.229.15.9', '8.8.8.8']
end

dns_suffix 'Set DNS Suffix' do
  interface_name 'ethernet'
  use_regex_for_interface true
  suffix 'alaska.edu'
  register true
end
```

## Development

### Requirements

+ [ChefDK](https://downloads.chef.io/chef-dk/)
+ [Vagrant](https://www.vagrantup.com/)
+ [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
+ Install dependency tree with `berks install`
+ Vagrant WinRM plugin:  `vagrant plugin install vagrant-winrm`

### Windows Server 2016 Box

This cookbook was tested using the base box at

`\\fbk-tss-store1.apps.ad.alaska.edu\Department\Technology Support Services\Engineering\Packer Boxes\win2016core-virtualbox.box`

If this box has not been cached by Vagrant, it can be placed (without .box extension) in the kitchen-generated directory

`.kitchen/kitchen-vagrant/kitchen-se-win-baseline-default-win2016gui-virtualbox/.vagrant/machines/default/virtualbox`

or added to Vagrant using the shell command

`vagrant box add <name> <base_box>.box`

Alternative base boxes can be built, for example using [boxcutter](https://github.com/boxcutter/windows).
