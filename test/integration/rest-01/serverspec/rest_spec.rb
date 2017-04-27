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

describe 'Kafka Rest' do
  # Relaunch kafka-rest if it failed to be sure it had a working Kafka
  if `systemctl show kafka-rest -p ExecMainStatus` == 'ExecMainStatus=1'
    `systemctl restart kafka-rest`
  end

  it 'is running' do
    expect(service('kafka-rest')).to be_running
  end

  it 'is launched at boot' do
    expect(service('kafka-rest')).to be_enabled
  end

  (1..10).each do |try|
    out = `ss -tunl | grep -- :8082`
    break unless out.empty?
    puts "Waiting Rest to launch… (##{try}/10)"
    sleep(5)
  end

  it 'is listening on port 8082' do
    expect(port(8082)).to be_listening
  end
end

describe 'Kafka Rest Configuration' do
  describe file('/etc/kafka-rest/kafka-rest.properties') do
    its(:content) { should eq <<-eos.gsub(/^ {4}/, '') }
    # Produced by Chef -- changes will be overwritten

    port=8082
    id=kafka-rest-1
    schema.registry.url=http://registry-kitchen-01.kitchen:8081
    zookeeper.connect=zookeeper-kafka.kitchen:2181/kafka-kitchen
    eos
  end

  describe file('/etc/kafka-rest/log4j.properties') do
    its(:content) { should contain 'log4j.rootLogger=INFO, stdout' }
    its(:content) { should contain '# Kitchen=true' }
  end
end

# Waiting registry to be up
curl = 'http_proxy="" curl -sS -X'
header = '-H "Content-Type: application/vnd.schemaregistry.v1+json"'
url = 'http://registry-kitchen-01.kitchen:8081'

(1..10).each do |try|
  subjects = `#{curl} GET #{header} #{url}/subjects 2> /dev/null`
  break if subjects.include?('key')
  puts "Rest waiting to Schema Registry to be ready… (##{try}/5)"
  sleep(5)
end

# Test if the service is working correctly with all its dependencies
describe 'With Kafka Rest' do
  curl = 'http_proxy="" curl -sS -X'
  url = 'http://localhost:8082'

  it 'We can get the list of topics' do
    topics = `#{curl} GET "#{url}/topics"`
    expect(topics).to include('"_schemas"')
  end

  # Values send to Kafka
  values = { 'binary' => '"S2Fma2E="', 'avro' => '{"name":"testUser"}' }

  # Test producers
  values.each do |id, _value|
    it "We can produce a #{id} message to the topic test-#{id}" do
      header = "-H 'Content-Type: application/vnd.kafka.#{id}.v1+json'"
      topic_url = "#{url}/topics/test-#{id}"

      # Data field used by our producers
      data = {
        'binary' => "{\"records\":[{\"value\":#{values['binary']}}]}",
        'avro' => '{"value_schema":"{\"type\":\"record\",\"name\":\"User\",' \
          '\"fields\":[{\"name\":\"name\",\"type\":\"string\"}]}",' \
          "\"records\":[{\"value\":#{values['avro']}}]}"
      }

      (1..10).each do |_|
        offsets = `#{curl} POST #{header} --data '#{data[id]}' "#{topic_url}"`
        exp = /{"offsets":
        \[{"partition":\d+,"offset":\d+,"error_code":null,"error":null}\],
        "key_schema_id":null,"value_schema_id":
        #{id == 'avro' ? '\d+' : 'null'}}/x
        expect(offsets).to match(exp)
      end
    end
  end

  sleep(60)

  # Test consumers
  values.each do |id, value|
    it "We can create a #{id} consumer and get some messages with it" do
      # Specific variables
      create_header = '-H "Content-Type: application/vnd.kafka.v1+json"'
      consume_header = "-H 'Accept: application/vnd.kafka.#{id}.v1+json'"
      data = "--data '{\"id\": \"#{id}\", \"format\": \"#{id}\", " \
        "\"auto.offset.reset\": \"smallest\"}'"
      consumer = "#{url}/consumers/#{id}_consumer"
      instance = "#{consumer}/instances/#{id}"

      # Delete existing current consumers
      `#{curl} DELETE #{instance}`

      # Create the consumer
      create = `#{curl} POST #{create_header} #{data} #{consumer}`
      exp = "{\"instance_id\":\"#{id}\",\"base_uri\":\"#{instance}\"}"
      expect(create).to eq(exp)

      sleep(60)

      # Consume messages
      read = `#{curl} GET #{consume_header} #{instance}/topics/test-#{id}`
      k = '"key":null'
      t = '"topic":null'
      expect(read).to match(
        /\[({#{k},"value":#{value},"partition":\d+,"offset":\d+,#{t}},?)+\]/
      )
    end
  end
end
