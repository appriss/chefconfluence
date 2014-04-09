
#
# Cookbook Name:: confluence
# Recipe:: default
#
# Copyright 2013, Appriss Inc.
#
# All rights reserved - Do Not Redistribute
#
#
require 'uri'
include_recipe 'java'
#include_recipe 'apache2'
#include_recipe 'apache2::mod_rewrite'
#include_recipe 'apache2::mod_proxy'
#include_recipe 'apache2::mod_ssl'
include_recipe 'labrea'

confluence_base_dir = File.join(node[:confluence][:install_path],node[:confluence][:base_name])

# Create a system user account on the server to run the Atlassian Confluence server
user node[:confluence][:run_as] do
  system true
  shell  '/bin/bash'
  action :create
end

# Create a home directory for the Atlassian Confluence user
directory node[:confluence][:home] do
  owner node[:confluence][:run_as]
end

# Install or Update the Atlassian Confluence package
labrea "atlassian-confluence" do
  source node[:confluence][:source]
  version node[:confluence][:version]
  install_dir node[:confluence][:install_path]
  config_files [File.join("atlassian-confluence-#{node[:confluence][:version]}","confluence","WEB-INF","classes","confluence-init.properties"),
	        File.join("atlassian-confluence-#{node[:confluence][:version]}","conf","server.xml")]
  notifies :run, "execute[configure confluence permissions]", :immediately
end

# Install database drivers if needed
if node[:confluence][:database][:type] == "oracle"
  uri = ::URI.parse(node[:confluence][:database][:driver_url])
  if uri.scheme == "s3"
    Chef::Log.info("URI #{node[:confluence][:database][:driver_url]}")
    Chef::Log.info("HOST #{uri.host}")
    Chef::Log.info("PATH #{uri.path}")
    s3_file ::File.join(confluence_base_dir,"lib","oracle_jdbc_driver.jar") do
      bucket uri.host
      remote_path uri.path
      owner node[:confluence][:run_as]
      #mode 0644
      action :create
    end
  else
    remote_file ::File.join(confluence_base_dir,"lib","oracle_jdbc_driver.jar") do
      source node[:confluence][:database][:driver_url]
      owner node[:confluence][:run_as]
      mode 0644
      action :create
    end
  end
end


# Set the permissions of the Atlassian Confluence directory
execute "configure confluence permissions" do
  command "chown -R #{node[:confluence][:run_as]} #{node[:confluence][:install_path]}"
  action :nothing
end

# Install main config file
template ::File.join(confluence_base_dir,"confluence","WEB-INF","classes","confluence-init.properties") do
  owner node[:confluence][:run_as]
  source "confluence-init.properties.erb"
  mode 0644
end

# Add the server.xml configuration for Crowd using the erb template
template ::File.join(confluence_base_dir,"conf","server.xml") do
  owner node[:confluence][:run_as]
  source "server.xml.erb"
  mode 0644
end

# Install service wrapper

wrapper_home = File.join(confluence_base_dir,node[:confluence][:jsw][:base_name])

labrea node[:confluence][:jsw][:base_name] do
  source node[:confluence][:jsw][:source]
  version node[:confluence][:jsw][:version]
  install_dir node[:confluence][:jsw][:install_path]
  config_files [File.join("#{node[:confluence][:jsw][:base_name]}-#{node[:confluence][:jsw][:version]}","conf","wrapper.conf")]
  notifies :run, "execute[configure wrapper permissions]", :immediately
end

# Configure wrapper permissions
execute "configure wrapper permissions" do
  command "chown -R #{node[:confluence][:run_as]} #{wrapper_home} #{wrapper_home}/*"
  action :nothing
end

# Configure wrapper
template File.join(wrapper_home,"conf","wrapper.conf") do
  owner node[:confluence][:run_as]
  source "wrapper.conf.erb"
  mode 0644
  variables({
    :wrapper_home => wrapper_home,
    :confluence_base_dir => confluence_base_dir
  })
end

#Install NewRelic if configured
if node[:confluence][:newrelic][:enabled]
  include_recipe 'newrelic::java-agent'
  #We need to explictly disable JSP autoinstrument
  newrelic_conf = File.join(confluence_base_dir, 'newrelic', 'newrelic.yml')
  ruby_block "disable autoinstrument for JSP pages." do 
    block do
      f = Chef::Util::FileEdit.new(newrelic_conf)
      f.search_file_replace(/auto_instrument: true/,'auto_instrument: false')
      f.write_file
    end
  end
end

# Create wrapper startup script
template File.join(wrapper_home,"bin","confluence") do
  owner node[:confluence][:run_as]
  source "confluence-startup.erb"
  mode 0755
  variables({
    :wrapper_home => wrapper_home
  })
  notifies :run, "execute[install startup script]", :immediately
end

execute "install startup script" do
  command "#{::File.join(wrapper_home,"bin","confluence")} install"
  action :nothing
  returns [0,1]
  notifies :restart, "service[confluence]", :immediately
end

service "confluence" do
  action :nothing
end

# Enable the Apache2 proxy_http module
#execute "a2enmod proxy_http" do
#  command "/usr/sbin/a2enmod proxy_http"
#  notifies :restart, resources(:service => "apache2")
#  action :run
#end

# Add the setenv.sh environment script using the erb template
#template File.join("#{node[:confluence][:install_path]}/atlassian-confluence","/bin/setenv.sh") do
#  owner node[:confluence][:run_as]
#  source "setenv.sh.erb"
#  mode 0644
#end

# Setup the virtualhost for Apache
#web_app "confluence" do
#  docroot File.join("#{node[:confluence][:install_path]}/atlassian-confluence","/") 
#  template "confluence.vhost.erb"
#  server_name node[:fqdn]
#  server_aliases [node[:hostname], "confluence"]
#end
