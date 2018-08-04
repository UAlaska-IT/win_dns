# frozen_string_literal: true

# Validate DNS is working
describe host('google.com') do
  it { should be_resolvable }
  it { should be_reachable }
end

script = <<-SCRIPT
  Get-WmiObject win32_NetworkAdapterConfiguration | Select DnsServerSearchOrder, DnsDomain
SCRIPT

describe powershell(script) do
  its('stdout') { should match '137.229.15.5, 137.229.15.9, 8.8.8.8' }
  its('stdout') { should match 'alaska.edu' }
end
