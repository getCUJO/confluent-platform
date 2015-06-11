Confluent Platform
==================

Description
-----------

Apache Kafka, an open source technology created and maintained by the founders
of Confluent, acts as a real-time, fault tolerant, highly scalable messaging
system. It is widely adopted for use cases ranging from collecting user
activity data, logs, application metrics, stock ticker data, and device
instrumentation. Its key strength is its ability to make high volume data
available as a real-time stream for consumption in systems with very different
requirements—from batch systems like Hadoop, to realtime systems that require
low-latency access, to stream processing engines that transform the data
streams as they arrive.

This infrastructure lets you build around a single central nervous system
transmitting messages to all the different systems and applications within your
company. Learn more on <http://confluent.io>.

This cookbook focuses on deploying Confluent Platform elements on your clusters
via Chef on *systemd* managed distributions.

Usage
-----

### Easy Setup


### Search


### Test

This cookbook is fully tested through the installation of a working 3-nodes
cluster in docker hosts. This uses kitchen, docker and some monkey-patching.

For more information, see *.kitchen.yml* and *test* directory.

### Local cluster

You can also use this cookbook to install a kafka cluster locally. By
running `kitchen converge`, you will have a 3-nodes cluster available on your
workstation, each in its own docker host.

You can access it by first adding dnsdock to your `/etc/resolv.conf` whose ip
is: `docker inspect --format '{{.NetworkSettings.IPAddress}}' dnsdock-kafka`

Then to produce some messages:

    kafka-console-producer.sh \
      --broker-list kafka-kitchen-01.kitchen:9092 \
      --topic my_topic

And to read them:

    kafka-console-consumer.sh \
      --zookeeper zookeeper-kafka.kitchen/kafka-kitchen \
      --topic my_topic \
      --from-beginning

Changes
-------

### 1.0.0:

- Initial version with Centos 7 support

Requirements
------------

### Cookbooks

From <https://supermarket.chef.io>:
- cluster-search
- yum

### Gems

From <https://rubygems.org>:

- berkshelf
- test-kitchen
- kitchen-docker

### Platforms

A *systemd* managed distribution:
- RHEL Family 7, tested on Centos

Note: it should work fine on Debian 8 but the official docker image does not
allow systemd to work easily, so it could not be tested.

Attributes
----------

Recipes
-------

### default

### repository

Configure confluent repository.

### install-kafka

Install and fully configure Kafka by running *repository*, *kafka-package*,
*kafka-user*, *kafka-config* and *kafka-service*, in that order.

### kafka-package

Install kafka from confluent repository.

### kafka-user

Create kafka system user and group.

### kafka-config

Generate kafka configuration, search for a zookeeper cluster and other kafka
nodes thanks to cluster-search cookbook.

### kafka-service

Install kafka service for systemd, enable and start it. Install *java* package
by default.

Resources/Providers
-------------------

None.

Contributing
------------

You are more than welcome to submit issues and merge requests to this project.
Note however that this cookbook will probably not support another supervisor
than *systemd*.

### Commits

Your commits must pass `git log --check` and messages should be formated
like this (based on this excellent
[post](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)):

```
Summarize change in 50 characters or less

Provide more detail after the first line. Leave one blank line below the
summary and wrap all lines at 72 characters or less.

If the change fixes an issue, leave another blank line after the final
paragraph and indicate which issue is fixed in the specific format
below.

Fix #42
```

Also do your best to factor commits appropriately, ie not too large with
unrelated things in the same commit, and not too small with the same small
change applied N times in N different commits. If there was some accidental
reformatting or whitespace changes during the course of your commits, please
rebase them away before submitting the PR.

### Files

All files must be 80 columns width formatted (actually 79), exception when it
is not possible.

License and Author
------------------

- Author:: Samuel Bernard (<samuel.bernard@s4m.io>)

```text
Copyright:: 2015, Sam4Mobile

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
