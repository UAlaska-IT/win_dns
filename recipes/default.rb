# frozen_string_literal: true

tcb = 'win_dns'

include_recipe 'chef_run_recorder::default'

if node[tcb]['static_dns'] && !node[tcb]['nameservers'].nil?
  dns_client 'Static DNS' do
    interface_name node[tcb]['interface_alias']
    use_regex_for_interface true
    name_servers node[tcb]['nameservers']
  end
end

if node[tcb]['set_suffix'] && !node[tcb]['suffix'].nil?
  dns_suffix 'Set DNS Suffix' do
    interface_name node[tcb]['interface_alias']
    use_regex_for_interface true
    suffix node[tcb]['suffix']
    register node[tcb]['register']
  end
end
