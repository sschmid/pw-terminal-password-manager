# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [8.1.0] - 2024-09-29
### Added
- Refactor password generation to ensure desired length in low entropy environments
- `macos_keychain`: Add support for displaying multiline comments in fzf preview

### Fixed
- `gpg`: Fix edit removes account, url and notes
- `gpg`: Fix only printing first line of notes in fzf preview

## [8.0.0] - 2024-09-27
### Added
- Add `gpg` plugin
- Add support for adding url and notes for all plugins with `pw add [<name>] [<account>] [<url>] [<notes>]`
- Add `fzf` preview to all plugins when selecting an entry with `pw`
- `keepassxc`: Add support for creating items in groups
- `keepassxc`: Add key-file support
- `keepassxc`: Add YubiKey support
- Add automatic keychain discovery
- Add adding new entries interactively with `pw add`
- Accept `PW_GEN_LENGTH` and `PW_GEN_CLASS` as arguments for `pw gen [<length>] [<class>]`
- Accept combined `pw` options like `pw -pk my-keychain`
- Accept lower and upper case reply when asking to delete item
- Run hooks in a subshell to avoid affecting the current shell
- Print all matching plugins when multiple plugins match file type or file extension

### Fixed
- `keepassxc`: Fix not showing password prompt with pw unlock

### Changed
- Rename hook functions to `pw::register` and `pw::register_with_extension`
- Plugins use `PW_NAME`, `PW_ACCOUNT`, `PW_URL` and `PW_NOTES` instead of positional arguments

### Removed
- Remove `pw --help`

### Other
- Add test coverage with `kcov`

## [7.0.0] - 2024-09-09
### Added
- Add shorter bash version check
- Add optional `fzf` format to `ls`
- Add more tests
- Add `_skip_if_github_action()` for tests
- Add uninstall instructions. Closes #5

### Fixed
- Support leading and trailing spaces in entry name and account
- Clear clipboard after generating password
- `macos_keychain`: Fix getting entry with empty name or account
- `macos_keychain`: Fix removing entry with empty name or account
- `macos_keychain`: Fix `ls` splitting on `=`
- `macos_keychain`: Accept keychain password from stdin to init
- `macos_keychain`: Accept keychain password from stdin to unlock

### Changed
- Drastically simplified plugin architecture and tests
- Migrate `macos_keychain` and tests to new plugin structure
- Migrate `keepassxc` and tests to new plugin structure

## [6.1.2] - 2024-05-18
### Fixed
- `macos_keychain:` Fix not opening keychains with absolute path

## [6.1.1] - 2024-05-17
### Fixed
- `keepassxc:` Exclude `Recycle Bin/` folder, not entry

### GitHub Actions
- Upgrade to `actions/checkout@v4`
- Install `shellcheck` instead of using docker image

## [6.1.0] - 2024-05-17
### Added
- Add sample plugin `src/plugins/sample` to demonstrate how to create a plugin

### Changed
- `keepassxc`: Sort entries in `ls`
- `keepassxc`: Exclude `Recycle Bin` from `ls`
- `keepassxc`: Show error message when providing wrong database password
- Extract `pw::clip_and_forget` from plugins
- Extract `pw::prompt_password` from plugins
- Print errors to `STDERR` instead of `STDOUT`

## [6.0.0] - 2024-05-13
### Added
- Introduce plugin architecture to support different password managers
- Add plugin for `macOS-keychain` and `keepassxc-cli`
- Add support for choosing from multiple keychains
- Update bats and add bats-file submodule

### Changed
- Change `pw init` to accept keychain name as argument
- Increase entry name padding in `pw ls`
- Don't automatically append `.keychain`

### Removed
- Remove `-a` option to search in all user keychains

## [5.1.0] - 2023-03-14
### Added
- Clear password from clipboard after 45 seconds

## [5.0.0] - 2022-10-31
### Changed
- Change `help` command to option `--help`

## [4.5.1] - 2022-10-11
### Added
- Display minimum bash version error message
- Upgrade to bee 1.4.0

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

[Unreleased]: https://github.com/sschmid/pw-terminal-password-manager/compare/8.1.0...HEAD
[8.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/8.0.0...8.1.0
[8.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/7.0.0...8.0.0
[7.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/6.1.2...7.0.0
[6.1.2]: https://github.com/sschmid/pw-terminal-password-manager/compare/6.1.1...6.1.2
[6.1.1]: https://github.com/sschmid/pw-terminal-password-manager/compare/6.1.0...6.1.1
[6.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/6.0.0...6.1.0
[6.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/5.1.0...6.0.0
[5.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/5.0.0...5.1.0
[5.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/4.5.1...5.0.0
[4.5.1]: https://github.com/sschmid/pw-terminal-password-manager/compare/4.5.0...4.5.1
[4.5.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/4.4.0...4.5.0
[4.4.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/4.3.0...4.4.0
[4.3.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/4.2.0...4.3.0
[4.2.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/4.1.0...4.2.0
[4.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/3.0.0...4.0.0
[3.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/2.3.0...3.0.0
[2.3.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/1.3.0...2.0.0
[1.3.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sschmid/pw-terminal-password-manager/releases/tag/1.0.0
