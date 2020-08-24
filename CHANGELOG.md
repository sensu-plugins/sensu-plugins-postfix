# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]

## [2.0.0] - 2020-08-24
### Breaking Changes
- Remove support for old Ruby (< 2.3)
- Remove kitchen test reliant on Sensu Core
- Bump sensu-plugin dependency from ~> 1.2 to ~> 4.0

### Changed
- Updated bundler dependancy to '~> 2.1'
- Updated rubocop dependency to '~> 0.81.0'
- Remediated rubocop issues
- Updated codeclimate-test-reporter to '~> 1.0'
- Updated rake dependency to '~> 13.0'

## [1.0.0] - 2017-07-26
### Breaking Change
- Remove support for Ruby 1.9.3 (@eheydrick)

### Added
- Testing on Ruby 2.4.1 (@Evesy)

### Fixed
- Fix the integration tests (@RoboticCheese)

## [0.1.0] - 2016-01-29
### Added
- Add support to `check-mailq` for inspecting each Postfix queue individually
- Add a `check-mail-delay` script to support alerting by age of queue items

### Fixed
- metrics-mailq.rb: don't output stderr when the mail queue is empty

## [0.0.3] - 2015-07-14
### Changed
- executable tag in gemspec
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - 2015-05-30
### Fixed
- executable tag in gemspec

## 0.0.1 - 2015-04-30
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/2.0.0...HEAD
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.1.0...1.0.0
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.0.3...0.1.0
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.0.1...0.0.2
