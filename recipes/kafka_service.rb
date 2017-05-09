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

# Configuration files to be subscribed
config_files = [
  '/etc/kafka/server.properties',
  '/etc/kafka/log4j.properties',
  '/etc/systemd/system/kafka.service'
].map do |path|
  "template[#{path}]"
end

# Configure systemd unit with options
unit = node[cookbook_name]['kafka']['unit'].to_hash
unit['Service']['ExecStart'] = [
  unit['Service']['ExecStart']['start'],
  node[cookbook_name]['kafka']['cli_opts'].map do |key, opt|
    # remove key if value is string 'nil' (using 'string' is not a bug)
    "#{key}#{"=#{opt}" unless opt.to_s.empty?}" unless opt == 'nil'
  end,
  unit['Service']['ExecStart']['end']
].flatten.compact.join(" \\\n  ")

auto_restart = node[cookbook_name]['kafka']['auto_restart']
# Create unit
systemd_unit 'kafka.service' do
  enabled true
  active true
  masked false
  static false
  content unit
  triggers_reload true
  action %i[create enable start]
  subscribes :restart, config_files if auto_restart
end
