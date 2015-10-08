name 'confluent-platform'
maintainer 'Sam4Mobile'
maintainer_email 'samuel.bernard@s4m.io'
license 'Apache 2.0'
description 'Install/Configure confluent-platform'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://gitlab.com/s4m-chef-repositories/confluent-platform'
issues_url 'https://gitlab.com/s4m-chef-repositories/confluent-platform/issues'
version '1.0.0'

supports 'centos',  '>= 7.1'

depends 'cluster-search'
depends 'yum'
