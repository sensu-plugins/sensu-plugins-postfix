#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
- Add `check-smtp-ehlo` for checking whether SMTP is functional

## [0.1.0] - 2016-01-29
### Added
- Add support to `check-mailq` for inspecting each Postfix queue individually
- Add a `check-mail-delay` script to support alerting by age of queue items

### Fixed
- metrics-mailq.rb: do not output stderr when the mail queue is empty

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

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.1.0...HEAD
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.0.3...0.1.0
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-postfix/compare/0.0.1...0.0.2
