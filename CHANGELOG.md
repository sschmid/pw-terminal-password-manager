# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.5.0] - 2022-06-03
### Added
- Add pw gen

### Fixed
- Fix generated passwords end with `)`

## [4.4.0] - 2022-03-01
### Added
- Add PW_GEN_LENGTH (default: 35)

## [4.3.0] - 2022-01-18
### Added
- Add support for spaces in entry names, accounts and keychains

## [4.2.0] - 2022-01-11
### Added
- Add custom fzf prompt

## [4.1.0] - 2022-01-03
### Added
- Add fzf to pw edit
- Add support for account only entries

### Fixed
- Copy password without trailing newline
- Fix copying non-existent entry did not fail

## [4.0.0] - 2021-12-21
### Added
- Add pw edit
- Add tests
- Add GitHub action to run tests

### Changed
- Copy password by default instead of printing

## [3.0.0] - 2021-11-11
### Added
- Print keychain in pw rm

### Changed
- Change default keychain to login.keychain

## [2.3.0] - 2021-10-31
### Added
- Support -a for pw::get

## [2.2.0] - 2021-10-31
### Added
- Generate password when empty
- Less verbose rm output

## [2.1.0] - 2021-10-30
### Fixed
- Fix potentially removing wrong entry when no account is specified

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

[Unreleased]: https://github.com/sschmid/pw/compare/4.5.0...HEAD
[4.5.0]: https://github.com/sschmid/pw/compare/4.4.0...4.5.0
[4.4.0]: https://github.com/sschmid/pw/compare/4.3.0...4.4.0
[4.3.0]: https://github.com/sschmid/pw/compare/4.2.0...4.3.0
[4.2.0]: https://github.com/sschmid/pw/compare/4.1.0...4.2.0
[4.1.0]: https://github.com/sschmid/pw/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/sschmid/pw/compare/3.0.0...4.0.0
[3.0.0]: https://github.com/sschmid/pw/compare/2.3.0...3.0.0
[2.3.0]: https://github.com/sschmid/pw/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/sschmid/pw/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/sschmid/pw/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/sschmid/pw/compare/1.3.0...2.0.0
[1.3.0]: https://github.com/sschmid/pw/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/sschmid/pw/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/sschmid/pw/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sschmid/pw/releases/tag/1.0.0
