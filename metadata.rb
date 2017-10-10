name 'confluent-platform'
maintainer 'Make.org'
maintainer_email 'sre@make.org'
license 'Apache-2.0'
description 'Install/Configure confluent-platform'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://gitlab.com/chef-platform/confluent-platform'
issues_url 'https://gitlab.com/chef-platform/confluent-platform/issues'
version '2.5.0'

chef_version '>= 12.14'

supports 'centos', '>= 7.1'

depends 'cluster-search'
