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
execute 'registry:systemd-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

unit_path = node['confluent-platform']['unit_path']
template "#{unit_path}/schema-registry.service" do
  mode '0644'
  source 'schema-registry.service.erb'
  notifies :run, 'execute[registry:systemd-reload]', :immediately
end

# Configuration files to be subscribed
if node['confluent-platform']['registry']['auto_restart']
  config_files = [
    '/etc/schema-registry/schema-registry.properties',
    '/etc/schema-registry/log4j.properties'
  ].map do |path|
    "template[#{path}]"
  end
else config_files = []
end

# Enable/Start service
service 'schema-registry' do
  provider Chef::Provider::Service::Systemd
  supports status: true, restart: true
  action [:enable, :start]
  subscribes :restart, config_files
end
