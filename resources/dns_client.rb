# frozen_string_literal: true

# A dns_client provides a single action to configure DNS queries for networking interfaces
resource_name :dns_client
provides :dns_client, os: 'windows'

default_action :set_server_ips

property :name, String, name_property: true
property :interface_name, String, default: 'ethernet' # Not case sensitive
property :use_regex_for_interface, [true, false], default: true # Use regex to match interfaces
property :name_servers, Array, required: true # An array of nameserver IPs as strings

extend ::DNS::Helper

action :set_server_ips do
  set_server_ips_helper(@new_resource)
end

action_class.class_eval do
  include ::DNS::Helper

  def set_server_ips_helper(new_resource)
    ensure_dns_server_ips(new_resource)
  end
end
