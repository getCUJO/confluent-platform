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

version = node.attribute[cookbook_name]['version'].split('.')[0..1].join('.')

case node['platform_family']
when 'rhel'
  yum_repository 'confluent' do
    description "Confluent platform v#{version} repository"
    baseurl "http://packages.confluent.io/rpm/#{version}"
    gpgkey "http://packages.confluent.io/rpm/#{version}/archive.key"
    action :create
  end
when 'debian'
  apt_repository 'confluent' do
    uri "http://packages.confluent.io/deb/#{version}"
    components %w[stable main]
    arch 'all'
    key "http://packages.confluent.io/deb/#{version}/archive.key"
  end
end
