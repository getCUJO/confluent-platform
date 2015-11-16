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
config = node['confluent-platform']['registry']['config'].to_hash

# Search Zookeeper cluster
zookeeper = cluster_search(node['confluent-platform']['zookeeper'])
return if zookeeper == nil # Not enough nodes
zk_connection = zookeeper['hosts'].map do |host|
  host + ":2181"
end.join(',') + node['confluent-platform']['kafka']['zk_chroot']
config['kafkastore.connection.url'] = zk_connection

# Write configuration
template "/etc/schema-registry/schema-registry.properties" do
  source "properties.erb"
  mode '644'
  variables :config => config
end

template "/etc/schema-registry/log4j.properties" do
  source "properties.erb"
  mode '644'
  variables :config => node['confluent-platform']['registry']['log4j']
end
