#
# Cookbook Name:: dnsmasq
# Recipe:: default
#
# Copyright 2011, NREL
#
# All rights reserved - Do Not Redistribute
#

package "dnsmasq"

template "/etc/dnsmasq.conf" do
  source "dnsmasq.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[dnsmasq]"
end

if(node[:dnsmasq][:nameservers] && node[:dnsmasq][:nameservers].any?)
  template "/etc/resolv.dnsmasq" do
    source "resolv.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :reload, "service[dnsmasq]"
  end
else
  file "/etc/resolv.dnsmasq" do
    action :delete
  end
end

service "dnsmasq" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

service "dnsmasq-network" do
  service_name "network"
  supports :status => true, :restart => true
  action :nothing
end

ruby_block "dhclient-prepend-domain-name-servers" do
  block do
    line = "prepend domain-name-servers 127.0.0.1;"
    file = Chef::Util::FileEdit.new("/etc/dhcp/dhclient-eth0.conf")
    file.insert_line_if_no_match(line, line)
    file.write_file
  end
end

# Cleanup earlier attempt at persisting the 127.0.0.1 name server.
ruby_block "cleanup-dhclient-enter-hooks-attempt" do
  block do
    require "digest"
    digest = Digest::SHA256.hexdigest(File.read("/etc/dhclient-enter-hooks"))
    if(digest == "5375d8b40242893355e6e1d72c7f502db68ee9df8830555b91929d91959c3b85")
      FileUtils.rm("/etc/dhclient-enter-hooks")
    else
      Chef::Log.warn("/etc/dhclient-enter-hooks exists, but doesn't match expected content for removal... Leaving alone")
    end
  end
  only_if { File.exists?("/etc/dhclient-enter-hooks") }
end
