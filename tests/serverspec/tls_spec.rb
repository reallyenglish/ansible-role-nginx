require "spec_helper"
require "serverspec"

package = "nginx"
service = "nginx"
config_dir = "/etc/nginx"
user    = "nginx"
group   = "nginx"
ports   = [80, 443]
log_dir = "/var/log/nginx"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  user = "www"
  group = "www"
  config_dir = "/usr/local/etc/nginx"
  default_group = "wheel"
end
config = "#{config_dir}/nginx.conf"

describe package(package) do
  it { should be_installed }
end

if os[:family] == "freebsd"
  describe file("/etc/rc.conf.d/nginx") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^nginx_flags=""$/) }
  end
end

describe file("#{config_dir}/conf.d/foo.conf") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/^# FOO$/) }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(%r{^\s+include\s+#{config_dir}/mime\.types;$}) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
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

describe command("echo | openssl s_client -connect 127.0.0.1:443 -showcerts") do
  its(:stdout) { should match(/#{Regexp.escape("issuer=/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd/CN=foo.example.org")}/) }
  its(:stderr) { should match(/verify error:num=18:self signed certificate/) }
  its(:exit_status) { should eq 0 }
end
