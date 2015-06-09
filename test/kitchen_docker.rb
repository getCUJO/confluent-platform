#
# Author:: Samuel Bernard (<samuel.bernard@s4m.io>)
# Special thanks to Shane da Silva for:
# https://medium.com/brigade-engineering/\
#       reduce-chef-infrastructure-integration-test-times-by-75\
#       -with-test-kitchen-and-docker-bf638ab95a0a
#
# Cookbook Name:: confluent-platform
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

require 'kitchen/driver/docker'

module Kitchen
  module Driver
    class Docker < Kitchen::Driver::SSHBase

      def login_command(state)
        LoginCommand.new(
          "docker exec -it #{state[:container_id]} bash -c 'TERM=xterm bash'",
          [])
      end

      def rm_container(state)
        container_id = state[:container_id]
        # Fix for kafka slowing the destroy
        docker_command("exec #{container_id} systemctl kill kafka -s9 || true")
        docker_command("exec #{container_id} systemctl halt")
        docker_command("wait #{container_id}") # Wait for shutdown
        docker_command("rm #{container_id}")
      end

    end
  end
end
