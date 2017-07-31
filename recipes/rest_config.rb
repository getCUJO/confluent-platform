#
# Copyright (c) 2015-2016 Sam4Mobile, 2017 Make.org
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

# To be used in service
node.run_state[cookbook_name] ||= {}
node.run_state[cookbook_name]['rest'] ||= {}

# Will be set to false if searchs succeed, at the end of this recipe
node.run_state[cookbook_name]['rest']['interrupted'] = true

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

# Get default configuration
config = node[cookbook_name]['rest']['config'].to_hash

# Search other Kafka Rest
rest = cluster_search(node[cookbook_name]['rest'])
return if rest.nil? # Not enough nodes
config['id'] = "kafka-rest-#{rest['my_id']}"

# Search Schema Registry
registry = cluster_search(node[cookbook_name]['registry'])
return if registry.nil? # Not enough nodes
registry_connection = registry['hosts'].map do |host|
  "http://#{host}:#{node[cookbook_name]['registry']['config']['port']}"
end.join(',')
config['schema.registry.url'] = registry_connection

# Search Zookeeper cluster
zookeeper = cluster_search(node[cookbook_name]['zookeeper'])
return if zookeeper.nil? # Not enough nodes
zk_connection = zookeeper['hosts'].map do |host|
  "#{host}:2181"
end.join(',') + node[cookbook_name]['kafka']['zk_chroot']
config['zookeeper.connect'] = zk_connection

# Write configurations
files = {
  '/etc/kafka-rest/kafka-rest.properties' => config,
  '/etc/kafka-rest/log4j.properties' => node[cookbook_name]['rest']['log4j']
}
node.run_state[cookbook_name]['rest']['conf_files'] = files.keys

files.each do |file, conf|
  template file do
    source 'properties.erb'
    mode '644'
    variables config: conf
  end
end

# Everything was fine
node.run_state[cookbook_name]['rest']['interrupted'] = false
