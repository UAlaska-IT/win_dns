# frozen_string_literal: true

tcb = 'win_dns'

include_recipe 'chef_run_recorder::default'

if node[tcb]['static_dns'] && ![tcb]['nameservers'].nil?
  dns_client 'Static DNS' do
    interface_name node[tcb]['interface_alias']
    use_regex_for_interface true
    name_servers node[tcb]['nameservers']
  end
end

if node[tcb]['set_suffix'] && ![tcb]['set_suffix'].nil?
  dns_suffix 'Set DNS Suffix' do
    interface_name node[tcb]['interface_alias']
    use_regex_for_interface true
    suffix node[tcb]['suffix']
    register node[tcb]['register']
  end
end
