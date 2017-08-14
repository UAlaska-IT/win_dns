# frozen_string_literal: true

if defined?(ChefSpec)
  ChefSpec::Runner.define_runner_method(:dns_client)

  def set_server_ips_dns_client(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:dns_client, :set_server_ips, resource)
  end

  ChefSpec::Runner.define_runner_method(:dns_suffix)

  def set_suffix_dns_suffix(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:dns_client, :set_server_ips, resource)
  end
end
