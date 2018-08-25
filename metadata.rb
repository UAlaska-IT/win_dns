# frozen_string_literal: true

name 'win_dns'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Provides resources for configuring DNS in Windows'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url 'https://github.com/ualaska-it/win_dns/issues' if respond_to?(:issues_url)
source_url 'https://github.com/ualaska-it/win_dns' if respond_to?(:source_url)

version '1.2.0'

# Windows 2008 and 2012 require WMF updates
supports 'windows', '>= 6.1' # Windows 2008R2 or 7, see https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions

chef_version '>= 13.0' if respond_to?(:chef_version)

depends 'windows'
