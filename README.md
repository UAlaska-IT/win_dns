# Windows DNS Cookbook

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

The custom resources in this cookbook implement the _mechanism_ for configuring both both the DNS client-server and server-suffix on Windows.  For an example of a _policy_ for how to configure DNS, see the se-win-baseline cookbook.

## Requirements

### Chef

This cookbook requires Chef 13+

### Platforms

Supported Platform Families:

* Windows

Platforms validated via Test Kitchen:

* Windows Server 2016
* Windows Server 2012
* Windows Server 2008R2
* Windows 10

Notes:

* This is a low-level cookbook with precondition that Powershell 5.0 is installed
  * Custom resources will not work with previous versions of Powershell
  * Windows 2008 and 2012 require WMF update to install Powershell 5.0
  * Powershell is not installed by this cookbook

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

## Attributes

Resources in this cookbook do not reference any attributes.

## Recipes

### win_dns::default

This recipe configures possibly both DNS client behavior and DNS suffix.

__Attributes__

Only interfaces matching the interface alias will be configured.

* `node['win_dns']['interface_alias']` - Defaults to `ethernet`.  The alias of the connection on which to configure client server and suffix.  Not case sensitive and used as a regular expression.  All interfaces that match the alias regex will be configured.

DNS client attributes:

* `node['win_dns']['static_dns']` - Defaults to `true`. Determines if static DNS client settings are applied to the system.
* `node['win_dns']['nameservers']` - Defaults to an array of UA name servers and a fallback Google server.  See attributes/dns.rb for the default values.

DNS suffix attributes:

* `node['win_dns']['set_dns_suffix']` - Defaults to `true`. Determines if a DNS suffix is configured for the system.  If set to `false`, the windows default of `localdomain` will not allow this host to be found via DNS lookup.
* `node['win_dns']['suffix']` - Defaults to `alaska.edu`.  The DNS suffix to configure for the chosen interface.
* `node['win_dns']['register']` - Defaults to `true`.  Determines if the host DNS name is registered.

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

Development should follow [GitHub Flow](https://guides.github.com/introduction/flow/) to foster some shared responsibility.

* Fork/branch the repository
* Make changes
* Fix all Rubocop (`rubocop`) and Foodcritic (`foodcritic .`) offenses
* Write smoke tests that reasonably cover the changes (`kitchen verify`)
* Pass all smoke tests
* Submit a Pull Request using Github
* Wait for feedback and merge from a second developer

### Requirements

For running tests in Test Kitchen a few dependencies must be installed.

* [ChefDK](https://downloads.chef.io/chef-dk/)
* [Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install the dependency tree with `berks install`
* Install the Vagrant WinRM plugin:  `vagrant plugin install vagrant-winrm`
