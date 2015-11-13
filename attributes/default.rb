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

# confluent version and general cookbook attributes
default['confluent-platform']['version']        = '1.0'
default['confluent-platform']['scala_version']  = '2.11.5'
default['confluent-platform']['java']['centos'] = 'java-1.8.0-openjdk-headless'

# Cluster search configuration
# To understand the following attributes, look at 'cluster-search' README

# Zookeeper cluster
default['confluent-platform']['zookeeper']['role']  = 'zookeeper-cluster'
default['confluent-platform']['zookeeper']['hosts'] = []
default['confluent-platform']['zookeeper']['size']  = 3

# Kafka cluster
default['confluent-platform']['kafka']['role']  = 'kafka-cluster'
default['confluent-platform']['kafka']['hosts'] = []
default['confluent-platform']['kafka']['size']  = 3

# Schema Registry cluster
default['confluent-platform']['registry']['role']  = 'schema-registry-cluster'
default['confluent-platform']['registry']['hosts'] = []
default['confluent-platform']['registry']['size']  = 3

# Kafka Rest cluster
default['confluent-platform']['rest']['role']  = 'kafka-rest-cluster'
default['confluent-platform']['rest']['hosts'] = []
default['confluent-platform']['rest']['size']  = 3

# Kafka configuration
# Always use a chroot in Zookeeper
default['confluent-platform']['kafka']['zk_chroot'] =
  "/#{node['confluent-platform']['kafka']['role']}"

default['confluent-platform']['kafka']['user'] = 'kafka'
default['confluent-platform']['kafka']['auto_restart'] = 'true'

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

# Kafka JVM configuration
default['confluent-platform']['kafka']['jvm_opts'] = {
  '-Xms4g' => nil,
  '-Xmx4g' => nil,
  '-XX:+UseG1GC' => nil,
  '-XX:MaxGCPauseMillis' => 20,
  '-XX:InitiatingHeapOccupancyPercent' => 35
}

# Kafka JMX configuration
default['confluent-platform']['kafka']['jmx_opts'] = {
  '-Dcom.sun.management.jmxremote' => nil,
  '-Dcom.sun.management.jmxremote.authenticate' => false,
  '-Dcom.sun.management.jmxremote.ssl' => false,
  '-Dcom.sun.management.jmxremote.port' => 8090,
  '-Djava.rmi.server.hostname' => node['fqdn']
}

# Kafka log4j configuration
default['confluent-platform']['kafka']['log4j'] = {
  'kafka.logs.dir' => 'logs',
  'log4j.rootLogger' => 'INFO, stdout ',
  'log4j.appender.stdout' => 'org.apache.log4j.ConsoleAppender',
  'log4j.appender.stdout.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.stdout.layout.ConversionPattern' => '[%d] %p %m (%c)%n',
  'log4j.appender.kafkaAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.kafkaAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.kafkaAppender.File' => '${kafka.logs.dir}/server.log',
  'log4j.appender.kafkaAppender.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.kafkaAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.stateChangeAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.stateChangeAppender.DatePattern' =>
    "'.'yyyy-MM-dd-HH",
  'log4j.appender.stateChangeAppender.File' =>
    '${kafka.logs.dir}/state-change.log',
  'log4j.appender.stateChangeAppender.layout' =>
    'org.apache.log4j.PatternLayout',
  'log4j.appender.stateChangeAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.requestAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.requestAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.requestAppender.File' =>
    '${kafka.logs.dir}/kafka-request.log',
  'log4j.appender.requestAppender.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.requestAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.cleanerAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.cleanerAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.cleanerAppender.File' => '${kafka.logs.dir}/log-cleaner.log',
  'log4j.appender.cleanerAppender.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.cleanerAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.controllerAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.controllerAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.controllerAppender.File' =>
    '${kafka.logs.dir}/controller.log',
  'log4j.appender.controllerAppender.layout' =>
    'org.apache.log4j.PatternLayout',
  'log4j.appender.controllerAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.logger.kafka' => 'INFO, kafkaAppender',
  'log4j.logger.kafka.network.RequestChannel$' => 'WARN, requestAppender',
  'log4j.additivity.kafka.network.RequestChannel$' => 'false',
  'log4j.logger.kafka.request.logger' => 'WARN, requestAppender',
  'log4j.additivity.kafka.request.logger' => 'false',
  'log4j.logger.kafka.controller' => 'TRACE, controllerAppender',
  'log4j.additivity.kafka.controller' => 'false',
  'log4j.logger.kafka.log.LogCleaner' => 'INFO, cleanerAppender',
  'log4j.additivity.kafka.log.LogCleaner' => 'false',
  'log4j.logger.state.change.logger' => 'TRACE, stateChangeAppender',
  'log4j.additivity.state.change.logger' => 'false'
}


# Schema Registry configuration
default['confluent-platform']['registry']['user'] = 'registry'
default['confluent-platform']['registry']['auto_restart'] = 'true'
default['confluent-platform']['registry']['config'] = {
  'port' => '8081',
  'kafkastore.connection.url' => 'localhost:2181',
  'kafkastore.topic' => '_schemas',
  'debug' => 'false'
}

default['confluent-platform']['registry']['log4j'] = {
  'log4j.rootLogger' => 'INFO, stdout',
  'log4j.appender.stdout' => 'org.apache.log4j.ConsoleAppender',
  'log4j.appender.stdout.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.stdout.layout.ConversionPattern' => '[%d] %p %m (%c:%L)%n',
  'log4j.logger.kafka' => 'ERROR, stdout',
  'log4j.logger.org.apache.zookeeper' => 'ERROR, stdout',
  'log4j.logger.org.apache.kafka' => 'ERROR, stdout',
  'log4j.logger.org.I0Itec.zkclient' => 'ERROR, stdout',
  'log4j.additivity.kafka.server' => 'false',
  'log4j.additivity.kafka.consumer.ZookeeperConsumerConnector' => 'false'
}

# Schema Registry JVM configuration
default['confluent-platform']['registry']['jvm_opts'] = {
  '-Xms1g' => nil,
  '-Xmx1g' => nil,
  '-XX:+UseG1GC' => nil,
  '-XX:MaxGCPauseMillis' => 20,
  '-XX:InitiatingHeapOccupancyPercent' => 35
}

# Schema Registry JMX configuration
default['confluent-platform']['registry']['jmx_opts'] = {
  '-Dcom.sun.management.jmxremote' => nil,
  '-Dcom.sun.management.jmxremote.authenticate' => false,
  '-Dcom.sun.management.jmxremote.ssl' => false,
  '-Dcom.sun.management.jmxremote.port' => 8091,
  '-Djava.rmi.server.hostname' => node['fqdn']
}

# Kafka Rest configuration
default['confluent-platform']['rest']['user'] = 'rest'
default['confluent-platform']['rest']['auto_restart'] = 'true'
default['confluent-platform']['rest']['config'] = {}
default['confluent-platform']['rest']['log4j'] = {
  'log4j.rootLogger' => 'INFO, stdout',
  'log4j.appender.stdout' => 'org.apache.log4j.ConsoleAppender',
  'log4j.appender.stdout.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.stdout.layout.ConversionPattern' => '[%d] %p %m (%c:%L)%n'
}

# Kafka Rest JVM configuration
default['confluent-platform']['rest']['jvm_opts'] = {
  '-Xms1g' => nil,
  '-Xmx1g' => nil,
  '-XX:+UseG1GC' => nil,
  '-XX:MaxGCPauseMillis' => 20,
  '-XX:InitiatingHeapOccupancyPercent' => 35
}

# Kafka Rest JMX configuration
default['confluent-platform']['rest']['jmx_opts'] = {
  '-Dcom.sun.management.jmxremote' => nil,
  '-Dcom.sun.management.jmxremote.authenticate' => false,
  '-Dcom.sun.management.jmxremote.ssl' => false,
  '-Dcom.sun.management.jmxremote.port' => 8092,
  '-Djava.rmi.server.hostname' => node['fqdn']
}
