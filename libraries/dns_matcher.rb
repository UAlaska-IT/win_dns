# frozen_string_literal: true

if defined?(ChefSpec)
  ChefSpec.define_matcher(:dns_client)

  def set_server_ips_dns_client(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:dns_client, :set_server_ips, resource)
  end

  ChefSpec.define_matcher(:dns_suffix)

  def set_suffix_dns_suffix(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:dns_suffix, :set_suffix, resource)
  end
end
