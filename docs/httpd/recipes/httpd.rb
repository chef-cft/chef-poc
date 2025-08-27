#
# Cookbook:: httpd
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.

case node['platform']
when 'ubuntu', 'debian'
  package 'apache2' do
    action :install
  end
when 'almalinux', 'centos', 'fedora', 'oracle', 'rocky', 'amazon'
  package 'httpd' do
    action :install
  end
when 'opensuseleap'
  package 'nginx' do
    action :install
  end
else
  Chef::Log.warn("No web server installation defined for platform: #{node['platform']}")
end

# Add a basic index.html to the default web directory and ensure the service is started for each platform
case node['platform']
when 'ubuntu', 'debian'
  file '/var/www/html/index.html' do
    content '<html><body><h1>Hello from your Chef recipe!</h1></body></html>'
    mode '0644'
    owner 'root'
    group 'root'
  end
  service 'apache2' do
    action [:enable, :start]
  end
when 'almalinux', 'centos', 'fedora', 'oracle', 'rocky', 'amazon'
  file '/var/www/html/index.html' do
    content '<html><body><h1>Hello from your Chef recipe!</h1></body></html>'
    mode '0644'
    owner 'root'
    group 'root'
  end
  service 'httpd' do
    action [:enable, :start]
  end
when 'opensuseleap'
  file '/srv/www/htdocs/index.html' do
    content '<html><body><h1>Hello from your Chef recipe!</h1></body></html>'
    mode '0644'
    owner 'root'
    group 'root'
  end
  service 'nginx' do
    action [:enable, :start]
  end
end