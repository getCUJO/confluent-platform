#
# Author:: Samuel Bernard (<samuel.bernard@s4m.io>)
# Cookbook Name:: kafka-cluster
# Recipe:: install-kafka
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

# Install Kafka with configured scala version
scala_version = node.attribute['confluent-platform']['scala_version']
package "confluent-kafka-#{scala_version}"

# Get default configuration
config = {}.merge! node['confluent-platform']['kafka']['config']

# Search zookeeper cluster
zookeeper = cluster_search(node['confluent-platform']['zookeeper'])
return if zookeeper == nil # Not enough nodes
zk_connection = zookeeper['hosts'].map { |h| h + ":2181" }.join(',')
zk_connection += node['confluent-platform']['kafka']['zk_chroot']
config['zookeeper.connect'] = zk_connection

# Search other Kafka
kafka = cluster_search(node['confluent-platform']['kafka'])
return if kafka == nil
config['broker.id'] = kafka['my_id']

# Write configuration
template "/etc/kafka/server.properties" do
  source "properties.erb"
  mode '644'
  variables :config => config
#  notifies :restart, "service[kafka]"
end
