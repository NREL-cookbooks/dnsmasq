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

replace_or_add "resolv-set-options" do
  path "/etc/resolv.conf"
  pattern "options .*"
  line "options attempts:5 timeout:2"
end

service "dnsmasq-network" do
  service_name "network"
  supports :status => true, :restart => true
end

replace_or_add "dhclient-prepend-domain-name-servers" do
  path "/etc/dhcp/dhclient-eth0.conf"
  pattern "prepend domain-name-servers.*"
  line "prepend domain-name-servers 127.0.0.1;"
  notifies :restart, "service[dnsmasq-network]"
end
