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
