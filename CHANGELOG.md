# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2021-10-30
### Fixed
- Remove entry matching empty account

## [2.0.0] - 2021-10-30
### Added
- Support empty account
- pw ls sorts entries

### Changed
- Default account is empty instead of $USER
- Select custom keychain with -k only

## [1.3.0] - 2021-10-30
### Added
- Add pw open
- Add pw -k <keychain>
- Add pw lock
- Add pw unlock

## [1.2.0] - 2021-10-29
### Added
- Ask before removing entry using pw rm
- Use tab for columns
- pw ls given keychain
- Update readme

## [1.1.0] - 2021-10-28
### Added
- Add -a option to search all user keychains

## [1.0.0] - 2021-10-28
### Added
- Add pw
- Add bee support
- Add install script
- Add readme

[Unreleased]: https://github.com/sschmid/pw/compare/2.1.0...HEAD
[2.1.0]: https://github.com/sschmid/pw/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/sschmid/pw/compare/1.3.0...2.0.0
[1.3.0]: https://github.com/sschmid/pw/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/sschmid/pw/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/sschmid/pw/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sschmid/pw/releases/tag/1.0.0
