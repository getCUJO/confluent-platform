#
# Copyright (c) 2015-2016 Sam4Mobile
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

describe 'Schema Registry' do
  it 'is running' do
    expect(service('schema-registry')).to be_running
  end

  it 'is launched at boot' do
    expect(service('schema-registry')).to be_enabled
  end

  it 'is listening on port 8081' do
    expect(port(8081)).to be_listening
  end
end

describe 'Schema Registry Configuration' do
  describe file('/etc/schema-registry/schema-registry.properties') do
    its(:content) { should eq <<-eos.gsub(/^ {4}/, '') }
    # Produced by Chef -- changes will be overwritten

    port=8081
    kafkastore.connection.url=zookeeper-kafka.kitchen:2181/kafka-kitchen
    kafkastore.topic=_schemas
    debug=false
    avro.compatibility.level=backward
    eos
  end

  describe file('/etc/schema-registry/log4j.properties') do
    its(:content) { should contain 'log4j.rootLogger=INFO, stdout' }
    its(:content) { should contain '# Kitchen=true' }
  end
end

describe 'With Schema Registry Rest Interface' do
  curl = 'http_proxy="" curl -sS -X'
  header = '-H "Content-Type: application/vnd.schemaregistry.v1+json"'
  url = 'http://localhost:8081'
  data = '--data \'{"schema": "{\"type\": \"string\"}"}\''
  schema_id = nil

  it 'We can register a new version of a schema under the subject "key"' do
    id = `#{curl} POST #{header} #{data} #{url}/subjects/key/versions`
    exp = /\{"id":(\d+)\}/
    schema_id = exp.match(id)[1]
    expect(schema_id).not_to be_nil
  end

  it 'We can register a new version of a schema under the subject "value"' do
    id = `#{curl} POST #{header} #{data} #{url}/subjects/value/versions`
    expect(id).to match(/\{"id":\d+\}/)
  end

  it 'We can list all subjects' do
    subjects = `#{curl} GET #{header} #{url}/subjects`
    expect(subjects).to include('key', 'value')
  end

  it 'We can list all schema versions registered under the subject "value"' do
    versions = `#{curl} GET #{header} #{url}/subjects/value/versions`
    expect(versions).to match(/\[(\d+,?)+\]/)
  end

  it 'We can fetch a schema by its global unique id' do
    expect(schema_id).not_to be_nil
    unless schema_id.nil?
      schema = `#{curl} GET #{header} #{url}/schemas/ids/#{schema_id}`
      expect(schema).to eq('{"schema":"\"string\""}')
    end
  end

  it 'We can fetch version 1 of the schema registered under subject "value"' do
    schema = `#{curl} GET #{header} #{url}/subjects/value/versions/1`
    expect(schema).to match(
      /{"subject":"value","version":1,"id":\d+,"schema":"\\\"string\\\""}/
    )
  end

  it 'We can fetch the most recently registered "value" schema' do
    schema = `#{curl} GET #{header} #{url}/subjects/value/versions/latest`
    expect(schema).to match(
      /{"subject":"value","version":\d+,"id":\d+,"schema":"\\\"string\\\""}/
    )
  end

  it 'We can check whether a schema has been registered under subject "key"' do
    schema = `#{curl} POST #{header} #{data} #{url}/subjects/key`
    expect(schema).to match(
      /{"subject":"key","version":\d+,"id":\d+,"schema":"\\\"string\\\""}/
    )
  end

  it 'We can test the compatibility of a schema with latest "value" schema' do
    compatible = `#{curl} POST #{header} #{data} \
      #{url}/compatibility/subjects/value/versions/latest`
    expect(compatible).to eq('{"is_compatible":true}')
  end
end
