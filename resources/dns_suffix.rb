# frozen_string_literal: true

# A dns_suffix provides a single action to configure DNS suffix for a connection alias
resource_name :dns_suffix
provides :dns_suffix, os: 'windows'

default_action :set_suffix

property :interface_name, String, default: 'ethernet' # Not case sensitive
property :use_regex_for_interface, [true, false], default: true # Use regex to match interfaces
property :suffix, String, required: true # The suffix
property :register, [true, false], default: true # Register this connection

action :set_suffix do
  set_suffix_helper(@new_resource)
end

action_class.class_eval do
  include ::DNS::Helper

  def set_suffix_helper(new_resource)
    ensure_dns_suffix(new_resource)
  end
end
