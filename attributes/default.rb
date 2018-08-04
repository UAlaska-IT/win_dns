# frozen_string_literal: true

tcb = 'win_dns'

default[tcb]['interface_alias'] = 'ethernet'

# Attribute to determine if machine pulls DNS from DHCP or statically assigned
default[tcb]['static_dns'] = true
default[tcb]['nameservers'] = ['137.229.15.5', '137.229.15.9', '8.8.8.8']

# DNS Node settings
default[tcb]['set_dns_suffix'] = true
default[tcb]['suffix'] = 'alaska.edu'
default[tcb]['register'] = true
