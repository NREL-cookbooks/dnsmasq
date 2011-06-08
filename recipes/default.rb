#
# Cookbook Name:: dnsmasq
# Recipe:: default
#
# Copyright 2011, NREL
#
# All rights reserved - Do Not Redistribute
#

# include_recipe "resolver"

package "dnsmasq"

template "/etc/dnsmasq.conf" do
  source "dnsmasq.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[dnsmasq]"
end

service "dnsmasq" do
  supports :status => true, :restart => true
  action [:enable, :start]
end

