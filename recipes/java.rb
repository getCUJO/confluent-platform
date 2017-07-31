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

# Java is needed by all components of confluent. We may install it with package
java = node[cookbook_name]['java']
return if java == ''

java_package = java[node['platform']]
return if java_package.to_s.empty?

package_retries = node[cookbook_name]['package_retries']

package java_package do
  retries package_retries unless package_retries.nil?
end
