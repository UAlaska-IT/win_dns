# frozen_string_literal: true

tcb = 'win_dns'

if node[tcb]['static_dns']
  dns_client 'Static DNS' do
    interface_name node[tcb]['interface_alias']
    use_regex_for_interface true
    name_servers node[tcb]['nameservers']
  end
end

if node[tcb]['set_dns_suffix']
  dns_suffix 'Set DNS Suffix' do
    interface_name node[tcb]['interface_alias']
    use_regex_for_interface true
    suffix node[tcb]['suffix']
    register node[tcb]['register']
  end
end
