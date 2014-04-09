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
default[:confluence][:newrelic][:enabled]  = false
default[:confluence][:newrelic][:version]  = "3.5.0"
default[:confluence][:newrelic][:app_name] = node['hostname']
# Confluence doesn't support OpenJDK http://confluence.atlassian.com/browse/CONF-16431
# FIXME: There are some hardcoded paths like JAVA_HOME
set[:java][:install_flavor]    = "oracle"
set[:oracledb][:jdbc][:install_dir] = ::File.join(node[:confluence][:install_path],node[:confluence][:base_name],"lib")

normal[:newrelic][:'java-agent'][:install_dir]   = ::File.join(node[:confluence][:install_path],node[:confluence][:base_name],"newrelic")
normal[:newrelic][:'java-agent'][:app_user] = node[:confluence][:run_as]
normal[:newrelic][:'java-agent'][:app_group] = node[:confluence][:run_as]
normal[:newrelic][:'java-agent'][:https_download] = "https://download.newrelic.com/newrelic/java-agent/newrelic-agent/#{node[:confluence][:newrelic][:version]}/newrelic-agent-#{node[:confluence][:newrelic][:version]}.jar"
normal[:newrelic][:'java-agent'][:jar_file] = "newrelic-agent-#{node[:confluence][:newrelic][:version]}.jar"
normal[:newrelic][:application_monitoring][:logfile] = ::File.join(node[:confluence][:home], "log", "newrelic.log")
normal[:newrelic][:application_monitoring][:appname] = node[:confluence][:newrelic][:app_name]

