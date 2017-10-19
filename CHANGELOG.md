Changelog
=========

2.5.0
-----

Breaking changes:

- drop support for Kakfa < 0.9.0

Main:

- feat: use auto-generated broker.id by default
  + Stop using search IDs to set broker.id. Set it by default to -1 to let
    Kafka generates it itself.
  + You can override this behavior by setting kafka/config/broker.id to the
    ID you want for each node.
  + Note: Setting the broker id to -1 should not affect an existing cluster
    that is already running. The auto broker ID generation is only used when
    there is no known broker ID. If you had a previously assigned ID, it
    will keep that ID.

Misc:

- docs: minor fix on kitchen suites description
- test: revert condition on molinillo to be < 0.6.0

2.4.0
-----

Main:

- fix: do not try to create a nil directory (aka do not need to have
  kafka.logs.dir key in kafka/log4j configuration)

Misc:

- style(rubocop): fix latest offences, mostly heredoc delimiters

2.3.0
-----

Main:

- set confluent default version to 3.3.0
- fix(Chef 13): do not set retries if package\_retries is nil
- fix #2: setting java to "" work as expected
- fix #3: nil error when search return to wait nodes

Tests:

- force molinillo to be < 0.6.0 to fix tests
- fix condition to restart a service in tests
- use .gitlab-ci.yml template [20170731]
- strengthen rest test by parsing JSON

Misc:

- change default size for search
- set new contributing guide with karma style

2.2.0
-----

Main:

- Handover maintainance to Make.org
- Use confluent 3.2.1 by default, fix repository
- Fix metadata: license and set correct chef\_version (12.14)
- Remove yum cookbook dependency
- Refactoring services, use systemd\_unit resource
  + Factorize code by using a custom resource

Tests:

- Set build\_pull & always\_update in tests config
- Fix destroy in tests, stop converge in verify
- Use latest template for .gitlab-ci.yml [20170405]
- Fix #1: Fix kitchen tests (nondeterministic)
- Reduce memory usage for tests
- Make tests work in Gitlab CI shared runners

Misc:

- Fix misc rubocop offenses
- Use cookbook\_name alias everywhere

2.1.0
-----

Main:

- Default confluent version to install is set to 3.0
  + Scala version to install is set to 2.11
  + Mandatory option ssl.client.auth is added to registry config
- Make Systemd unit path configurable

Tests:

- Start Continuous Integration with gitlab-ci
- Add security opts for docker, add package retries
- Remove sleep in recipes, wait to strengthen tests

2.0.0
-----

Main:

- Switch to confluent 2.0
- Rename recipes to respect rubocop rules (breaking change)

Tests:

- Switch to docker\_cli, use prepared docker image
  + Switch kitchen driver from docker to docker\_cli
  + Use sbernard/centos-systemd-kitchen image instead of bare centos
  + Remove privileged mode :)
  + Remove some now useless monkey patching
  + Remove dnsdock, use docker DNS (docker >= 1.10)
  + Use "kitchen" network, create it if needed

Misc:

- Fix all rubocop offenses
- Use specific name for resources to avoid cloning
- Add more details on configuration in README

1.2.0
-----

Main:

- Clarify and fix JVM options for services
- Use to\_hash instead of dup to work on node values
- Improve readibility of default system user names

Fixes:

- Fix and clean the creation of Kafka work directories
- Fix zookeeper.connect chroot path

Test:

- Rationalize docker provision to limit images
- Fix typo in roles/rest-kitchen.json name
- Wait 15s after registry start to strengthen tests

Packaging:

- Reorganize README:
  + Move changelog from README to CHANGELOG
  + Move contribution guide to CONTRIBUTING.md
  + Reorder README, fix Gemfile missing
- Add Apache 2 license file
- Add missing chefignore
- Fix long lines in rest and registry templates

1.1.0
-----

- Cleaning, use only dependencies from supermarket

1.0.1
-----

- Set java-1.8.0-openjdk-headless as default java package

1.0.0
-----

- Initial version with Centos 7 support
