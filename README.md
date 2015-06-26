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
requirements—from batch systems like Hadoop, to real-time systems that require
low-latency access, to stream processing engines that transform the data
streams as they arrive.

This infrastructure lets you build around a single central nervous system
transmitting messages to all the different systems and applications within your
company. Learn more on <http://confluent.io>.

This cookbook focuses on deploying Confluent Platform elements on your clusters
via Chef on *systemd* managed distributions. At the moment, this includes
**Kafka**, **Schema Registry** and **Kafka Rest**.

Usage
-----

### Easy Setup

Default recipe does nothing. Each service **Kafka**, **Schema Registry** or
**Kafka Rest** will be installed by calling respectively recipe
[install-kafka](recipes/install-kafka.rb),
[install-registry](recipes/install-registry.rb) and
[install-rest](recipes/install-rest.rb).

### Search

The recommended way to use this cookbook is through the creation of a different
role per cluster, that is a role for **Kafka**, **Schema Registry** and
**Kafka Rest**. This enables the search by role feature, allowing a simple
service discovery.

See [roles](test/integration/roles) for some examples and *Cluster Search*
documentation for more information.

### Test

This cookbook is fully tested through the installation of the full platform
in docker hosts. This uses kitchen, docker and some monkey-patching.

If you run `kitchen list`, you will see 7 suites:
- dnsdock-centos-7
- zookeeper-centos-7
- kafka-01-centos-7
- kafka-02-centos-7
- kafka-03-centos-7
- registry-01-centos-7
- rest-01-centos-7

Each corresponds to a different node in the cluster.

For more information, see [.kitchen.yml](.kitchen.yml) and [test](test)
directory.

### Local cluster

Of course, the cluster you install by running `kitchen converge` is fully
working so you can use it as a local cluster to test your development (like a
new Kafka client). Moreover, compared to a single node cluster usually
installed on workstations, you can detected partition/timing/fault-tolerance
issues you could not because of the simplicity of a single-node system.

You can access it by adding the dnsdock used in the cluster as your main DNS
resolver: add
`docker inspect --format '{{.NetworkSettings.IPAddress}}' dnsdock-kafka`
in `/etc/resolv.conf`.

Then to produce some messages:

    kafka-console-producer.sh \
      --broker-list kafka-kitchen-01.kitchen:9092 \
      --topic my_topic

And to read them:

    kafka-console-consumer.sh \
      --zookeeper zookeeper-kafka.kitchen/kafka-kitchen \
      --topic my_topic \
      --from-beginning

Or you can use Rest API with http://rest-kitchen-01.kitchen:8082 and full
Schema Registry support, located at http://registry-kitchen-01.kitchen:8081.

Changes
-------

### 1.0.0:

- Initial version with Centos 7 support

Requirements
------------

### Cookbooks

Declared in [metadata.rb](metadata.rb).

### Gems

Declared in [Gemfile](Gemfile).

### Platforms

A *systemd* managed distribution:
- RHEL Family 7, tested on Centos

Note: it should work fine on Debian 8 but the official docker image does not
allow systemd to work easily, so it could not be tested.

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in [attributes/default.rb](attributes/default.rb).
Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

Recipes
-------

### default

Does nothing.

### repository

Configure confluent repository.

### install-*service*

Install and fully configure a given *service* by running *repository* and its
4 dedicated recipes: *package*, *user*, *config* and *service*, in that order.

### *service*-package

Install given *service* from confluent repository.

### *service*-user

Create given *service* system user and group.

### *service*-config

Generate *service* configuration. May search for dependencies (like Zookeeper
or other nodes of the same cluster) with the help of cluster-search cookbook.

### *service*-service

Install systemd unit for the given *service*, then enable and start it.

Note: install *java* package by default, can be disable by setting
`node['confluent-platform']['java']` to nil, "" or false. A platform specific
configuration is also possible.

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
