#
# Author:: Samuel Bernard (<samuel.bernard@s4m.io>)
# Cookbook Name:: kafka-cluster
# Recipe:: kafka-service
#
# Copyright (c) 2015 Sam4Mobile
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

# Config for systemd service
jmx_port = node['confluent-platform']['kafka']['jmx_port']
jmx_port = "-Dcom.sun.management.jmxremote.port=#{jmx_port}" if jmx_port != ""

# Install service file, reload systemd daemon if necessary
execute "systemd-reload" do
  command "systemctl daemon-reload"
  action :nothing
end

template "/usr/lib/systemd/system/kafka.service" do
  variables     :jmx_port => jmx_port
  mode          "0644"
  source        "kafka.service.erb"
  notifies      :run, 'execute[systemd-reload]', :immediately
end

#Java is needed by Kafka, can install it with package
java_package = node['confluent-platform']['java'][node[:platform]]
package java_package if java_package != ""

# Configuration files to be subscribed
if node['confluent-platform']['kafka']['auto_restart']
  config_files = [
    "/etc/kafka/server.properties",
    "/etc/kafka/log4j.properties"
  ].map do |path|
    "template[#{path}]"
  end
else config_files = []
end

# Enable/Start service
service "kafka" do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  subscribes :restart, config_files
end
