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

# Install service file, reload systemd daemon if necessary
execute 'kafka:systemd-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/usr/lib/systemd/system/kafka.service' do
  mode '0644'
  source 'kafka.service.erb'
  notifies :run, 'execute[kafka:systemd-reload]', :immediately
end

# Configuration files to be subscribed
if node['confluent-platform']['kafka']['auto_restart']
  config_files = [
    '/etc/kafka/server.properties',
    '/etc/kafka/log4j.properties'
  ].map do |path|
    "template[#{path}]"
  end
else config_files = []
end

# Enable/Start service
service 'kafka' do
  provider Chef::Provider::Service::Systemd
  supports status: true, restart: true, reload: true
  action [:enable, :start]
  subscribes :restart, config_files
end
