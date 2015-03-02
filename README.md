## Sensu-Plugins-postfix

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-postfix.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-postfix)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-postfix.svg)](http://badge.fury.io/rb/sensu-plugins-postfix)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postfix/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postfix)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postfix/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-postfix)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-postfix.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-postfix)

## Functionality

## Files
 * bin/check-mailq
 * bin/metrics-mailq

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-postfix -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-postfix`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-postfix' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-postfix' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

## Notes

[1]:[https://travis-ci.org/sensu-plugins/sensu-plugins-postfix]
[2]:[http://badge.fury.io/rb/sensu-plugins-postfix]
[3]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-postfix]
[4]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-postfix]
[5]:[https://gemnasium.com/sensu-plugins/sensu-plugins-postfix]
