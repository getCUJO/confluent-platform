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

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

# Get default configuration
config = node['confluent-platform']['rest']['config'].dup

# Search other Kafka Rest
rest = cluster_search(node['confluent-platform']['rest'])
return if rest == nil # Not enough nodes
config['id'] = "kafka-rest-#{rest['my_id']}"

# Search Schema Registry
registry = cluster_search(node['confluent-platform']['registry'])
return if registry == nil # Not enough nodes
registry_connection = registry['hosts'].map do |host|
  "http://#{host}:#{node['confluent-platform']['registry']['config']['port']}"
end.join(',')
config['schema.registry.url'] = registry_connection

# Search Zookeeper cluster
zookeeper = cluster_search(node['confluent-platform']['zookeeper'])
return if zookeeper == nil # Not enough nodes
zk_connection = zookeeper['hosts'].map do |host|
  host + ":2181" + node['confluent-platform']['kafka']['zk_chroot']
end.join(',')
config['zookeeper.connect'] = zk_connection

# Write configuration
template "/etc/kafka-rest/kafka-rest.properties" do
  source "properties.erb"
  mode '644'
  variables :config => config
end

template "/etc/kafka-rest/log4j.properties" do
  source "properties.erb"
  mode '644'
  variables :config => node['confluent-platform']['rest']['log4j']
end

# Set correct ownership to kafka log directories
[ '/var/log/kafka-rest', '/var/lib/kafka-rest' ].each do |dir|
  directory dir do
    owner node['confluent-platform']['rest']['user']
    group node['confluent-platform']['rest']['user']
    mode '0755'
    recursive true
    action :create
  end
end
