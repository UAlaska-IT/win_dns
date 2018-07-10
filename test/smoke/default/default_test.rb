# frozen_string_literal: true

# Validate DNS is working
describe host('google.com') do
  it { should be_resolvable }
  it { should be_reachable }
end
