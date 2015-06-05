#
# Author:: Samuel Bernard (<samuel.bernard@s4m.io>)
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

require 'kitchen/command'

module Kitchen
  module Command

    module RunAction
      alias_method :run_action_official, :run_action

      def run_action(action, instances, *args)
        # Extract dnsdock instance(s) to be able to launch it first
        # so it is ready for other containers
        dnsdocks = instances.select {|i| i.suite.name.include? "dnsdock" }
        services = instances - dnsdocks

        case action
        when :destroy
          run_action_official(action, instances, *args)
        when :test
          run_action_official(:destroy, instances)
          run_action_official(:create, dnsdocks)
          run_action_official(:create, services)
          run_action_official(:converge, instances)
          run_action_official(:verify, instances)
          run_action_official(:destroy, instances) if args.first == :passing
        else
          # Always run create first to initiaze all dockers
          run_action_official(:create, dnsdocks)
          run_action_official(:create, services)
          run_action_official(:converge, instances) if action == :verify
          run_action_official(action, instances, *args) if action != :create
        end
      end

    end

  end
end
