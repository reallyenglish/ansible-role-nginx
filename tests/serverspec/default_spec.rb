require "spec_helper"
require "serverspec"

package = "nginx"
service = "nginx"
config  = "/etc/nginx/nginx.conf"
user    = "nginx"
group   = "nginx"
ports   = [PORTS]
log_dir = "/var/log/nginx"
db_dir  = "/var/lib/nginx"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/nginx.conf"
  db_dir = "/var/db/nginx"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("nginx") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/nginx") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
