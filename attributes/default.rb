#
# Cookbook Name:: confluence
# Attributes:: confluence
#
# Copyright 2008-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# The openssl cookbook supplies the secure_password library to generate random passwords
default[:confluence][:virtual_host_name]  = "confluence.#{domain}"
default[:confluence][:virtual_host_alias] = "confluence.#{domain}"
# type-version-standalone
default[:confluence][:base_name]	    = "atlassian-confluence"
default[:confluence][:version]           = "2.1.1"
default[:confluence][:install_path]      = "/opt/confluence"
default[:confluence][:home]              = "/var/lib/confluence"
default[:confluence][:source]            = "http://www.atlassian.com/software/confluence/downloads/binary/#{node[:confluence][:base_name]}-#{node[:confluence][:version]}.tar.gz"
default[:confluence][:run_as]          = "confluence"
default[:confluence][:min_mem]	    = 256
default[:confluence][:max_mem]	    = 512
default[:confluence][:ssl]		    = true
default[:confluence][:database][:type]   = "mysql"
default[:confluence][:database][:host]     = "localhost"
default[:confluence][:database][:user]     = "confluence"
default[:confluence][:database][:name]     = "confluence"
default[:confluence][:service][:type]      = "jsw"
if node[:opsworks][:instance][:architecture]
  default[:confluence][:jsw][:arch]          = node[:opsworks][:instance][:architecture].gsub!(/_/,"-")
else
  default[:confluence][:jsw][:arch]          = node[:kernel][:machine].gsub!(/_/,"-")
end
default[:confluence][:jsw][:base_name]     = "wrapper-linux-#{node[:confluence][:jsw][:arch]}"
default[:confluence][:jsw][:version]       = "3.5.20"
default[:confluence][:jsw][:install_path]  = ::File.join(node[:confluence][:install_path],"#{node[:confluence][:base_name]}")
default[:confluence][:jsw][:source]        = "http://wrapper.tanukisoftware.com/download/#{node[:confluence][:jsw][:version]}/wrapper-linux-#{node[:confluence][:jsw][:arch]}-#{node[:confluence][:jsw][:version]}.tar.gz"
# Confluence doesn't support OpenJDK http://confluence.atlassian.com/browse/CONF-16431
# FIXME: There are some hardcoded paths like JAVA_HOME
set[:java][:install_flavor]    = "oracle"
set[:oracledb][:jdbc][:install_dir] = ::File.join(node[:confluence][:install_path],node[:confluence][:base_name],"lib")

# new relic installed?
default[:confluence][:newrelic][:enabled] = false
if node[:confluence][:newrelic][:enabled] = true
	set[:newrelic][:app_user] = node[:confluence][:newrelic][:app_user] if node[:confluence][:newrelic][:app_user]
	set[:newrelic][:app_group] = node[:confluence][:newrelic][:app_group] if node[:confluence][:newrelic][:app_group]
	set[:newrelic][:install_dir] = node[:confluence][:newrelic][:install_dir] if node[:confluence][:newrelic][:install_dir]
	set[:newrelic][:server_monitoring][:license] = node[:confluence][:newrelic][:server_license] if node[:confluence][:newrelic][:server_license]
	set[:newrelic][:application_monitoring][:license] = node[:confluence][:newrelic][:app_license] if node[:confluence][:newrelic][:app_license]
	set[:newrelic][:https_download] = node[:confluence][:newrelic][:https_download] if node[:confluence][:newrelic][:https_download]
	set[:newrelic][:jar_file] = node[:confluence][:newrelic][:jar_file] if node[:confluence][:newrelic][:jar_file]
end
