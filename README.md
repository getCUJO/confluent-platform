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
requirements from batch systems like Hadoop, to real-time systems that require
low-latency access, to stream processing engines that transform the data
streams as they arrive.

This infrastructure lets you build around a single central nervous system
transmitting messages to all the different systems and applications within your
company. Learn more on <http://confluent.io>.

This cookbook focuses on deploying Confluent Platform elements on your clusters
via Chef on *systemd* managed distributions. At the moment, this includes
**Kafka**, **Schema Registry** and **Kafka Rest**.

Requirements
------------

### Cookbooks and gems

Declared in [metadata.rb](metadata.rb) and in [Gemfile](Gemfile).

### Platforms

A *systemd* managed distribution:
- RHEL Family 7, tested on Centos

Note: it should work quite fine on Debian 8 (with some attributes tuning) but
the official docker image does not allow systemd to work easily, so it could
not be tested.

Usage
-----

### Easy Setup

Default recipe does nothing. Each service **Kafka**, **Schema Registry** or
**Kafka Rest** will be installed by calling respectively recipe
[install\_kafka](recipes/install_kafka.rb),
[install\_registry](recipes/install_registry.rb) and
[install\_rest](recipes/install_rest.rb).

By default, this cookbook installs *openjdk* from the official repositories
*(openjdk 8 on centos 7)* in **services** recipe, just before
launching the service. You can deactivate this behavior by setting
`node['confluent-platform']['java']` to `""`, or choose your package by setting
the package name in `node['confluent-platform']['java'][node[:platform]]`.

### Search

The recommended way to use this cookbook is through the creation of a different
role per cluster, that is a role for **Kafka**, **Schema Registry** and
**Kafka Rest**. This enables the search by role feature, allowing a simple
service discovery.

In fact, there are two ways to configure the search:
1. with a static configuration through a list of hostnames (attributes `hosts`
   like in `['confluent-platform']['kafka']['hosts']`)
2. with a real search, performed on a role (attributes `role` and `size`
   like in `['confluent-platform']['kafka']['role']`). The role should be in
   the run-list of all nodes of the cluster. The size is a safety and should be
   the number of nodes in the cluster.

If hosts is configured, `role` and `size` are ignored.

See [roles](test/integration/roles) for some examples and
[Cluster Search][cluster-search] documentation for more information.

### Zookeeper Cluster

To install properly a **Kafka** cluster, you need a **Zookeeper** cluster.
This is not in the scope of this cookbook but if you need one, you should
consider using [Zookeeper Platform][zookeeper-platform].

The configuration of Zookeeper hosts use search and is done similarly as for
**Kafka**, **Schema Registry** and **Kafka Rest** hosts, _ie_ with a static
list of hostnames or by using a search on a role.

### Test

This cookbook is fully tested through the installation of the full platform
in docker hosts. This uses kitchen, docker and some monkey-patching.

If you run `kitchen list`, you will see 5 suites:
- zookeeper-centos-7
- kafka-01-centos-7
- kafka-02-centos-7
- registry-01-centos-7
- rest-01-centos-7

Each corresponds to a different node in the cluster. They are connected through
a bridge network named *kitchen*, which is created if necessary.

For more information, see [.kitchen.yml](.kitchen.yml) and [test](test)
directory.

### Local cluster

Of course, the cluster you install by running `kitchen converge` is fully
working so you can use it as a local cluster to test your development (like a
new Kafka client). Moreover, compared to a single node cluster usually
installed on workstations, you can detected partition/timing/fault-tolerance
issues you could not because of the simplicity of a single-node system.

You can access it by using internal DNS of the docker network named *kitchen*
or by declaring each node in your hosts file. You can get each IP by
running:

    docker inspect --format \
      '{{.NetworkSettings.Networks.kitchen.IPAddress}}' container_name

Then to produce some messages:

    kafka-console-producer.sh \
      --broker-list kafka-kitchen-01.kitchen:9092 \
      --topic my_topic

And to read them:

    kafka-console-consumer.sh \
      --zookeeper zookeeper-kafka.kitchen/kafka-kitchen \
      --topic my_topic \
      --from-beginning

Or you can use Rest API with [http://rest-kitchen-01.kitchen:8082]() and full
Schema Registry support, located at
[http://registry-kitchen-01.kitchen:8081]().

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

### install\_*service*

Install and fully configure a given *service* by running *repository* and its
4 dedicated recipes: *package*, *user*, *config* and *service*, in that order.

### *service*\_package

Install given *service* from confluent repository.

### *service*\_user

Create given *service* system user and group.

### *service*\_config

Generate *service* configuration. May search for dependencies (like Zookeeper
or other nodes of the same cluster) with the help of cluster-search cookbook.

### *service*\_service

Install systemd unit for the given *service*, then enable and start it.

Note: install *java* package (OpenJDK 8 on centos 7) by default, can be
disabled by setting `node['confluent-platform']['java']` to "". A platform
specific configuration for the package to install is also possible.

Resources/Providers
-------------------

None.

Changelog
---------

Available in [CHANGELOG](CHANGELOG).

Contributing
------------

Please read carefully [CONTRIBUTING.md](CONTRIBUTING.md) before making a merge
request.

License and Author
------------------

- Author:: Samuel Bernard (<samuel.bernard@gmail.com>)

```text
Copyright (c) 2015-2016 Sam4Mobile, 2017 Make.org

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

[cluster-search]: https://supermarket.chef.io/cookbooks/cluster-search
[zookeeper-platform]: https://supermarket.chef.io/cookbooks/zookeeper-platform
