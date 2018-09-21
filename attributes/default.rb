# frozen_string_literal: true

tcb = 'win_dns'

default[tcb]['interface_alias'] = 'ethernet'

# Attribute to determine if machine pulls DNS from DHCP or statically assigned
default[tcb]['static_dns'] = true
default[tcb]['nameservers'] = nil

# DNS Node settings
default[tcb]['set_suffix'] = true
default[tcb]['suffix'] = nil
default[tcb]['register'] = true
