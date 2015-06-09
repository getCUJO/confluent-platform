#
# Author:: Samuel Bernard (<samuel.bernard@s4m.io>)
# Cookbook Name:: confluent-platform
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

#
# Default attributes
#

# confluent versions
default['confluent-platform']['version']        = '1.0'
default['confluent-platform']['scala_version']  = "2.11.5"

# Zookeeper
# To understand the following attributes, look at 'cluster-search' doc
default['confluent-platform']['zookeeper']['role']  = 'zookeeper-cluster'
default['confluent-platform']['zookeeper']['hosts'] = []
default['confluent-platform']['zookeeper']['size']  = 3

# Cluster configuration
default['confluent-platform']['kafka']['role']  = 'kafka-cluster'
default['confluent-platform']['kafka']['hosts'] = []
default['confluent-platform']['kafka']['size']  = 3

# Kafka configuration, default provided by Kafka project
default['confluent-platform']['kafka']['config']      = {
  'broker.id' => 0,
  'port' => 9092,
  'num.network.threads' => 3,
  'num.io.threads' => 8,
  'socket.send.buffer.bytes' => 102400,
  'socket.receive.buffer.bytes' => 102400,
  'socket.request.max.bytes' => 104857600,
  'log.dirs' => '/var/lib/kafka',
  'num.partitions' => 1,
  'num.recovery.threads.per.data.dir' => 1,
  'log.retention.hours' => 168,
  'log.segment.bytes' => 1073741824,
  'log.retention.check.interval.ms' => 300000,
  'log.cleaner.enable' => false,
  'zookeeper.connect' => 'localhost:2181',
  'zookeeper.connection.timeout.ms' => 6000
}

default['confluent-platform']['kafka']['heap_opts'] = '-Xmx1G -Xms1G'
default['confluent-platform']['kafka']['performance_opts'] =
  '-server -XX:+UseParNewGC -XX:+UseConcMarkSweepGC \
  -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark \
  -XX:+DisableExplicitGC -Djava.awt.headless=true'
default['confluent-platform']['kafka']['jmx_opts'] =
  '-Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false'
default['confluent-platform']['kafka']['jmx_port'] = ''
default['confluent-platform']['kafka']['extra_opts'] = ''

default['confluent-platform']['kafka']['user'] = 'kafka'

# Always use a chroot in Zookeeper
default['confluent-platform']['kafka']['zk_chroot'] =
  "/#{node['confluent-platform']['kafka']['role']}"
