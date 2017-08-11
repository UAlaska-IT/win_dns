# frozen_string_literal: true

include Chef::Mixin::PowershellOut

module DNS
  # This module implements helpers that are used for DNS resources
  module Helper
    def empty_string?(string)
      return string.nil? || string.empty? || string == ''
    end

    def log_powershell_out(script_name, script_code)
      Chef::Log.debug("Running #{script_name} script: '#{script_code}'")
      cmd = powershell_out(script_code)
      Chef::Log.debug("Returned from #{script_name} script: '#{cmd.stdout}'")
      return cmd
    end

    def line_matches_or_empty?(line, regex)
      return true if empty_string?(line) # Happens on the edges
      return true if line.match?(/^-/) # Horizontal rule for header
      return true if line.match?(regex) # Header or footer
      return false
    end

    def parse_network_adapter_line(line, retval)
      Chef::Log.debug("Line: '#{line}'")
      line = line.strip
      Chef::Log.debug("Stripped line: '#{line}'")
      return if line_matches_or_empty?(line, /^ifIndex/) # The header
      space = line.index(' ')

      index = line[0, space]
      name = line[space + 1, line.length - space - 1]

      retval[name.downcase] = index
    end

    def parse_network_adapter_lines(cmd)
      retval = {}
      count = 0
      cmd.stdout.to_s.lines.each do |line|
        count += 1
        parse_network_adapter_line(line, retval)
      end
      Chef::Log.debug("Processed #{count} lines, found #{retval.size} interfaces")
      return retval
    end

    # Parse all network adapters as an array of hashes
    # Keys and values will be in lowercase
    def parse_network_adapters
      # netsh interface ipv4 show interfaces
      script_code = 'Get-NetAdapter | Sort-Object ifIndex | select ifIndex, Name'
      cmd = log_powershell_out('parse', script_code)

      interfaces = parse_network_adapter_lines(cmd)

      raise 'Could not parse network adapters' if interfaces.empty?
      return interfaces
    end

    def parse_server_address_line(line, retval)
      Chef::Log.debug("Line: '#{line}'")
      line = line.strip
      Chef::Log.debug("Stripped line: '#{line}'")
      return if line_matches_or_empty?(line, /^ServerAddresses/) # The header
      line = line[1, line.length - 2] # Strip braces
      line.split(', ').each do |ip|
        retval.push(ip)
      end
    end

    def run_server_address_script(interface_index)
      script_code = 'Get-DNSClientServerAddress -AddressFamily IPv4'\
        " -InterfaceIndex #{interface_index} | select ServerAddresses"
      cmd = log_powershell_out('parse', script_code)
      raise "Interface #{interface_index} not found" if cmd.stdout.to_s.match?(/No matching/)
      return cmd
    end

    # Parse all DNS server IPs for the given interface as an array
    def parse_server_addresses(interface_index)
      cmd = run_server_address_script(interface_index)

      retval = []
      count = 0
      cmd.stdout.to_s.lines.each do |line|
        count += 1
        parse_server_address_line(line, retval)
      end
      Chef::Log.debug("Processed #{count} lines, found #{retval.size} server IPs")
      return retval
    end

    def run_dns_suffix_script(interface_index)
      script_code = "Get-DNSClient -InterfaceIndex #{interface_index} | select ConnectionSpecificSuffix"
      cmd = log_powershell_out('parse', script_code)
      raise "Interface #{interface_index} not found" if cmd.stdout.to_s.match?(/No MSFT_DNSClient/)
      return cmd
    end

    def parse_dns_suffix_line(line, retval)
      Chef::Log.debug("Line: '#{line}'")
      line = line.strip
      Chef::Log.debug("Stripped line: '#{line}'")
      return if line_matches_or_empty?(line, /^ConnectionSpecificSuffix/) # The header
      retval.push(line)
    end

    # Parse DNS suffix for the given interface
    def parse_dns_suffix(interface_index)
      cmd = run_dns_suffix_script(interface_index)

      retval = []
      count = 0
      cmd.stdout.to_s.lines.each do |line|
        count += 1
        parse_dns_suffix_line(line, retval)
      end
      Chef::Log.debug("Processed #{count} lines, found #{retval.size} suffixes")
      raise 'Failed to parse DNS suffix' if retval.size != 1
      return retval.first
    end

    def diff_server_addresses(curr_servers, new_servers) # rubocop:disable Metrics/MethodLength # Just logging
      retval = []
      curr_servers.each do |ip|
        retval.push(ip) unless new_servers.include?(ip)
      end
      new_servers.each do |ip|
        retval.push(ip) unless curr_servers.include?(ip)
      end
      Chef::Log.debug("Current servers: #{curr_servers}")
      Chef::Log.debug("New servers: #{new_servers}")
      Chef::Log.debug("Diff servers: #{retval}")
      return retval
    end

    def set_dns_server_addresses(interface_index, addresses)
      script_code = "Set-DnsClientServerAddress -InterfaceIndex #{interface_index}"\
       " -ServerAddresses (\"#{addresses.join('","')}\")"
      cmd = log_powershell_out('dns server', script_code)
      raise 'Failed to set server addresses' unless empty_string?(cmd.stdout.to_s.strip)
    end

    def set_dns_suffix(interface_index, dns_suffix)
      script_code = "Set-DnsClient -InterfaceIndex #{interface_index} -ConnectionSpecificSuffix '#{dns_suffix.suffix}'"\
        " -RegisterThisConnectionsAddress $#{dns_suffix.register}"
      cmd = log_powershell_out('dns suffix', script_code)
      raise 'Failed to set server addresses' unless empty_string?(cmd.stdout.to_s.strip)
    end

    def process_interface(dns_client, iface_index)
      server_addresses = parse_server_addresses(iface_index)
      Chef::Log.debug("Current Addresses: #{server_addresses}")
      diff = diff_server_addresses(server_addresses, dns_client.name_servers)
      Chef::Log.debug("Diff addresses: #{diff}")

      return if diff.empty?
      converge_by "Set DNS Server Address #{dns_client.name_servers}" do
        set_dns_server_addresses(iface_index, dns_client.name_servers)
      end
    end

    def numbers_for_matching_interfaces(interfaces, dns_client)
      retval = []
      interfaces.each do |key, val|
        retval.push(val) if key.match?(Regexp.new(dns_client.interface_name.downcase))
      end
      Chef::Log.debug("Interface numbers: #{retval}")
      return retval
    end

    def ensure_dns_server_ips(dns_client)
      interfaces = parse_network_adapters
      Chef::Log.debug("Interfaces: #{interfaces}")

      interface_numbers = numbers_for_matching_interfaces(interfaces, dns_client)

      interface_numbers.each do |iface_index|
        process_interface(dns_client, iface_index)
      end
    end

    def numbers_of_matching_interfaces(interfaces, dns_suffix)
      interface_numbers = []
      interfaces.each do |key, val|
        interface_numbers.push(val) if key.match?(Regexp.new(dns_suffix.interface_name.downcase))
      end
      Chef::Log.debug("Interface numbers: #{interface_numbers}")
      return interface_numbers
    end

    # Returns true iff at least one interface was modified
    def set_dns_suffix_for_all_interfaces(interface_numbers, dns_suffix)
      interface_numbers.each do |iface_index|
        curr_suffix = parse_dns_suffix(iface_index)
        Chef::Log.debug("Current suffix: #{curr_suffix}")
        next if curr_suffix.casecmp(dns_suffix.suffix)
        converge_by "Set DNS Suffix #{iface_index} #{dns_suffix}" do
          set_dns_suffix(iface_index, dns_suffix)
        end
      end
    end

    def ensure_dns_suffix(dns_suffix)
      interfaces = parse_network_adapters
      Chef::Log.debug("Interfaces: #{interfaces}")

      interface_numbers = numbers_of_matching_interfaces(interfaces, dns_suffix)

      set_dns_suffix_for_all_interfaces(interface_numbers, dns_suffix)
    end
  end
end
