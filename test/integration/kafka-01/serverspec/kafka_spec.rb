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

require 'spec_helper'

# rubocop:disable Metrics/BlockLength

describe 'Kafka Daemon' do
  it 'is running' do
    expect(service('kafka')).to be_running
  end

  it 'is launched at boot' do
    expect(service('kafka')).to be_enabled
  end

  (1..10).each do |try|
    out = `ss -tunl | grep -- :9092`
    break unless out.empty?
    puts "Waiting Kafka to launch… (##{try}/10)"
    sleep(5)
  end

  it 'is listening on port 9092' do
    expect(port(9092)).to be_listening
  end
end

describe 'Kafka Configuration' do
  describe file('/etc/kafka/server.properties') do
    its(:content) { should contain <<-PROP.gsub(/^ {4}/, '') }
    # Produced by Chef -- changes will be overwritten

    broker.id=-1
    port=9092
    num.network.threads=2
    num.io.threads=2
    socket.send.buffer.bytes=102400
    socket.receive.buffer.bytes=102400
    socket.request.max.bytes=104857600
    log.dirs=/var/lib/kafka
    num.partitions=2
    num.recovery.threads.per.data.dir=1
    log.retention.hours=168
    log.segment.bytes=1073741824
    log.retention.check.interval.ms=300000
    log.cleaner.enable=false
    zookeeper.connect=zookeeper-kafka.kitchen:2181/kafka-kitchen
    zookeeper.connection.timeout.ms=60000
    default.replication.factor=2
    auto.create.topics.enable=true
    request.timeout.ms=300000
    PROP
  end

  describe file('/etc/kafka/log4j.properties') do
    its(:content) { should contain 'log4j.rootLogger=INFO, stdout' }
    its(:content) { should contain '# Kitchen=true' }
  end
end

describe 'Kafka Cluster' do
  brokers = [1, 2, 3].map do |i|
    "--broker-list kafka-kitchen-0#{i}.kitchen:9092"
  end
  zk = '--zookeeper zookeeper-kafka.kitchen/kafka-kitchen'
  topic = '--topic test'
  messages = %w[test_msg] * 6
  copts = '--from-beginning --max-messages 6'
  emute = '2> /dev/null'
  fmute = '> /dev/null  2>&1'

  it 'We be able to send message to topic "test"' do
    res = true
    i = 0
    messages.each do |m|
      res &= system(
        "echo #{m} | kafka-console-producer #{brokers[i]} #{topic} #{fmute}"
      )
      i = (i + 1) % 2
    end
    expect(res).to eq(true)
  end

  it 'Topic "test" should have been created' do
    expected = ['Topic:test', 'PartitionCount:2', 'ReplicationFactor:2']
    topics = `kafka-topics --describe #{zk} #{topic} #{emute}`.split[0..2]
    expect(topics).to eq(expected)
  end

  it 'Topic "test" should contain the messages we sent' do
    output = `kafka-console-consumer #{zk} #{topic} #{copts} #{emute}`
    output = output.split.sort
    expect(output).to eq(messages.sort)
  end
end
