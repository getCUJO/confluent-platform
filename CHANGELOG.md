Changelog
=========

2.0.0
-----

Main:
- Switch to confluent 2.0
- Rename recipes to respect rubocop rules (breaking change)

Tests:
- Switch to docker_cli, use prepared docker image
  + Switch kitchen driver from docker to docker_cli
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
- Use to_hash instead of dup to work on node values
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
