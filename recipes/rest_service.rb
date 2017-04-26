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

# Install service file, reload systemd daemon if necessary
execute 'kafka-rest:systemd-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

unit_path = node[cookbook_name]['unit_path']
template "#{unit_path}/kafka-rest.service" do
  mode '0644'
  source 'kafka-rest.service.erb'
  notifies :run, 'execute[kafka-rest:systemd-reload]', :immediately
end

# Configuration files to be subscribed
config_files = [
  '/etc/kafka-rest/kafka-rest.properties',
  '/etc/kafka-rest/log4j.properties'
].map do |path|
  "template[#{path}]"
end

auto_restart = node[cookbook_name]['rest']['auto_restart']
# Enable/Start service
service 'kafka-rest' do
  provider Chef::Provider::Service::Systemd
  supports status: true, restart: true
  action %i[enable start]
  subscribes :restart, config_files if auto_restart
end
