#
# Copyright (c) 2015-2017 Sam4Mobile, 2017 Make.org
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

# Monkey patch RunAction to create a suites scheduler that consider
# - each suite is a different node
# - some suites must converge first

require 'kitchen/command'

module Kitchen
  module Command
    module RunAction
      alias run_action_official run_action

      def run_action(action, instances, *args)
        # Define suites as global so we can use them to generates nodes
        # in CommonSandbox
        # rubocop:disable Style/GlobalVars
        $suites = @config.send(:data).suite_data
        # rubocop:enable Style/GlobalVars

        # Extract helper instance(s) to be able to launch it first
        # so it is ready for other containers
        helpers = [] # No need here
        services = instances - helpers

        if %i[destroy test create converge].include? action
          send("run_#{action}".to_sym,
               instances, services, helpers, args.first)
        else
          run_action_official(action, instances, *args)
        end
      end

      def run_destroy(instances, _services, _helpers, _type = nil)
        run_action_official(:destroy, instances)
      end

      def run_test(instances, services, helpers, type = nil)
        run_action_official(:destroy, instances)
        run_converge(instances, services, helpers)
        run_action_official(:verify, instances)
        run_action_official(:destroy, instances) unless type == :never
      rescue StandardError => error
        run_action_official(:destroy, instances) if type == :always
        raise error
      end

      def run_create(_instances, services, helpers, _type = nil)
        run_action_official(:create, helpers)
        run_action_official(:create, services)
      end

      def run_converge(_instances, services, helpers, _type = nil)
        run_create(nil, services, helpers)
        run_action_official(:converge, helpers)
        run_action_official(:converge, services)
      end
    end
  end
end
