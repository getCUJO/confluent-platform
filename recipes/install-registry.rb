#
# Author:: Samuel Bernard (<samuel.bernard@s4m.io>)
# Cookbook Name:: kafka-cluster
# Recipe:: install-registry
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

# Stand-alone meta-recipe to install Kafka and configure it
include_recipe "#{cookbook_name}::repository"
include_recipe "#{cookbook_name}::registry-package"
include_recipe "#{cookbook_name}::registry-user"
include_recipe "#{cookbook_name}::registry-config"
#include_recipe "#{cookbook_name}::registry-service"
