# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [12.1.0] - 2025-06-15
### Added
- Add plugin specific config parsing
- `macos_keychain`: Add `keychain_access_control` option to `pw.conf`

```ini
[macos_keychain]
keychain_access_control = always-allow
```

### Other
- Update to Bats v1.12.0

## [12.0.1] - 2025-06-12
### Fixed
- Fix regression: Copy password without trailing newline

### Other
- Add support for running tests with Podman
- Only copy essential test sources in Dockerfile

## [12.0.0] - 2025-05-25
### Upgrading to pw 12.0.0
The `pw` config file moved to `$XDG_CONFIG_HOME/pw/pw.conf` and the format has
changed to an INI-like format. `pw` can automatically move and migrate your
config to the new format:

```ini
[general]
password_length = 35
password_character_class = [:graph:]
clipboard_clear_time = 45

# pbcopy/pbpaste, xclip, xsel, and wl-copy/wl-paste are supported by default.
# If you're using a different clipboard manager, you can specify it here:
# copy = my-copy-command
# paste = my-paste-command

[plugins]
plugin = $PW_HOME/plugins/gpg
plugin = $PW_HOME/plugins/keepassxc
plugin = $PW_HOME/plugins/macos_keychain

[keychains]
# Put your keychains here for easy access
# keychain = $HOME/path/to/your/gpg/vault
# keychain = $HOME/path/to/your/keychain.kdbx
# keychain = $HOME/path/to/your/keychain.keychain-db
```

`pw` now installs to `/opt/pw` instead of `/usr/local/opt/pw`. No action is
required for this change. If you want to migrate to that new location uninstall
the old version and install the new one.

### Added
- Add `pw` config migration
- Add stricter config parsing
- Add support for custom copy/paste

### Fixed
- Fix config parsing failed when containing quotes

### Changed
- Move config to `$XDG_CONFIG_HOME/pw/pw.conf`
- Change `pw.conf` format to follow INI-style conventions
- Install `pw` to `/opt/pw` instead of `/usr/local/opt/pw`

## [11.0.0] - 2025-05-16
### Upgrading to pw 11.0.0
`pw` now respects the `$XDG_CONFIG_HOME` environment variable. Your existing `~/.pwrc`
file will be moved to the new location at `~/.config/pw/config`. If you have
`$XDG_CONFIG_HOME` set, the config file will be moved to `$XDG_CONFIG_HOME/pw/config`.
You can specify a custom config file with `pw -c <path>`.

### Added
- Add `.pwrc` migration
- Print supported clipboard tools when no clipboard tool is found

### Changed
- Use `$XDG_CONFIG_HOME` and fallback to `~/.config` for config path
- Move `~/.pwrc` to `~/.config/pw/config`

## [10.1.0] - 2025-05-10
### Changed
- Increase chunk_size for faster password generation
- Detect extension based on first `.`

### Other
- Add Dockerfile for openSUSE Tumbleweed
- Add `-m` option to run manual tests

## [10.0.0] - 2024-11-10
### Upgrading to pw 10.0.0
The `.pwrc` format has changed to an INI-like format. `pw` can automatically
migrate your `.pwrc` to the new format:

```ini
[config]
	password_length = 35
	password_character_class = [:graph:]
	clipboard_clear_time = 45

[plugins]
	$PW_HOME/plugins/gpg
	$PW_HOME/plugins/keepassxc
	$PW_HOME/plugins/macos_keychain

[keychains]
	secrets.keychain-db
	~/path/to/myproject.keychain-db
	~/path/to/keepassxc.kdbx
	~/path/to/gpg/secrets
```

The new format includes `config`, `plugins`, and `keychains` sections. The
`config` section includes `password_length`, `password_character_class`, and
`clipboard_clear_time`. You can still override these values with the environment
variables `PW_GEN_LENGTH`, `PW_GEN_CLASS`, and `PW_CLIP_TIME` respectively.

Additionally, with the new plugin section, you now have fine-grained control
over the plugins you want to use. You can specify your own plugins in addition
to the default plugins provided by `pw`.

### Added
- Set `SHELL` with `type -p bash`

### Changed
- Change `pwrc` to INI-like format including `config`, `plugins`, and `keychains` sections
- Move plugins out of `src` folder

### Other
- Run tests and coverage in parallel

## [9.2.3] - 2024-10-31
### Added
- Make `pw` work on Arch btw
- Improve entropy in password generation by reducing read size

### Fixed
- Fix character classes for BusyBox `tr` to avoid using `sed`

## [9.2.2] - 2024-10-27
### Added
- `keepassxc`: Display error messages prominently to avoid them being missed

### Fixed
- Fix fzf preview in docker container

## [9.2.1] - 2024-10-27
### Fixed
- Fix fzf yank to use new copy paste
- Discard `Xvfb` output when running docker container

## [9.2.0] - 2024-10-26
### Added
- Make `pw` work on Alpine Linux and Ubuntu
- Add Dockerfiles for building and testing `pw` on Alpine Linux and Ubuntu
- Add support for clipboard tools: `xclip`, `xsel`, `wl-clipboard`
- Faster copy to clipboard

## [9.1.1] - 2024-10-19
### Added
- `macos_keychain`: Remove unnecessary password prompt for show command
- `macos_keychain`: Remove unnecessary password prompt for fzf preview

## [9.1.0] - 2024-10-19
### Upgrading to pw 9.1.0
In order to increase security, the `macos_keychain` plugin won't automatically
add the `security` command to the keychain's access control list anymore.

Typically, when accessing keychain items added by other applications, the user
is prompted to `allow` or `always allow` access. However, when keychain entries are
added using the `security` command itself, the command is automatically granted
access to those items without future prompts. This can be a security risk, because
other applications can use the `security` command to access these items without
prompting the user.

`pw` changes this behaviour to reduce security risks by not automatically adding
the `security` command to the keychain's access control list. This way you have
full control over which applications can access your keychain items and decide
whether to allow or deny access.

If you want to add the `security` command to the keychain's access control list
by default, you can set the environment variable
`PW_MACOS_KEYCHAIN_ACCESS_CONTROL` to `always-allow`:

```bash
export PW_MACOS_KEYCHAIN_ACCESS_CONTROL="always-allow"
```

### Added
- Add `PW_MACOS_KEYCHAIN_ACCESS_CONTROL` to control access control list behavior
- Add "Security Considerations" section to readme

### Changed
- `macos_keychain`: Don't add `security` command to access control list by default
- `macos_keychain`: Don't unlock keychain for fzf preview
- `gpg`: Don't unlock keychain for fzf preview

## [9.0.0] - 2024-10-17
### Upgrading to pw 9.0.0
In order to increase security, plugins are no longer sourced. Instead they are
executed as separate scripts. This change also makes it easier to write and
maintain plugins. Please migrate your custom plugins to the new format.

Additionally, `.pwrc` is also no longer sourced and has been replaced by a
new format. `pw` can automatically migrate your `.pwrc` to the new format:

```bash
~/path/to/myproject.keychain-db
~/path/to/keepassxc.kdbx
~/path/to/gpg/secrets
```

### Added
- Add `.pwrc` migration
- Script optimizations
- Explicit variable declarations and strict scoping

### Changed
- Plugins are no longer sourced
- Plugins functions have been extracted to separate files
- `.pwrc` is no longer sourced and has a new format
- `.pwrc` is no longer created by default and is optional

### Removed
- Remove redirecting from tty
- Delete sample plugin

## [8.2.1] - 2024-10-08
### Fixed
- Fix generated password being empty

## [8.2.0] - 2024-10-08
### Added
- Add `pw show` to show details
- Add fzf shortcut `CTRL-Y` to copy (or print) details
- Add fzf shortcut `?` to toggle preview and make preview hidden by default
- Sort discovered keychains
- Display error message when no keychain was set
- `macos_keychain`: Show name, account, url and notes in fzf preview
- `keepassxc`: Enable yubikey and key-file fzf preview
- `gpg`: Add name to fzf preview

### Fixed
- Fix password prompt did trim whitespace
- Support multiline notes when adding new entry interactively

### Changed
- Sort using users default `LC_ALL`

### Removed
- Remove login.keychain-db as default keychain

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

[Unreleased]: https://github.com/sschmid/pw-terminal-password-manager/compare/12.1.0...HEAD
[12.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/12.0.1...12.1.0
[12.0.1]: https://github.com/sschmid/pw-terminal-password-manager/compare/12.0.0...12.0.1
[12.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/11.0.0...12.0.0
[11.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/10.1.0...11.0.0
[10.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/10.0.0...10.1.0
[10.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/9.2.3...10.0.0
[9.2.3]: https://github.com/sschmid/pw-terminal-password-manager/compare/9.2.2...9.2.3
[9.2.2]: https://github.com/sschmid/pw-terminal-password-manager/compare/9.2.1...9.2.2
[9.2.1]: https://github.com/sschmid/pw-terminal-password-manager/compare/9.2.0...9.2.1
[9.2.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/9.1.1...9.2.0
[9.1.1]: https://github.com/sschmid/pw-terminal-password-manager/compare/9.1.0...9.1.1
[9.1.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/9.0.0...9.1.0
[9.0.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/8.2.1...9.0.0
[8.2.1]: https://github.com/sschmid/pw-terminal-password-manager/compare/8.2.0...8.2.1
[8.2.0]: https://github.com/sschmid/pw-terminal-password-manager/compare/8.1.0...8.2.0
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
