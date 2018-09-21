# frozen_string_literal: true

# Validate DNS is working
describe host('google.com') do
  it { should be_resolvable }
  it { should be_reachable }
end

# DNS Servers
describe powershell('Get-WmiObject win32_NetworkAdapterConfiguration | Select DnsServerSearchOrder') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match '8.8.8.8, 8.8.8.4' }
end

# DNS Suffix
describe powershell('Get-WmiObject win32_NetworkAdapterConfiguration | Select DnsDomain') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match 'alaska.edu' }
end
