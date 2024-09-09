# 🔐 `pw` - Terminal Password Manager powered by `fzf`

`pw` is a command-line password manager unifying trusted password managers
like [macOS Keychain](https://developer.apple.com/documentation/security/keychain_services)
and [KeePassXC](https://keepassxc.org) in a single interface within the terminal.
It combines the security of your favourite password managers with the speed and
simplicity of the [fzf](https://github.com/junegunn/fzf) fuzzy finder and allows
you to interact with [various keychains](#example-using-multiple-keychains) effortlessly.

[![Tests](https://github.com/sschmid/pw/actions/workflows/tests.yaml/badge.svg)](https://github.com/sschmid/pw/actions/workflows/tests.yaml)
[![Latest release](https://img.shields.io/github/release/sschmid/pw.svg)](https://github.com/sschmid/pw/releases)
[![Twitter](https://img.shields.io/twitter/follow/s_schmid)](https://twitter.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fsschmid%2Fpw&screen_name=s_schmid&tw_p=followbutton)

# Why `pw`?

- **Unified Interface:** `pw` unifies trusted password managers in a single terminal interface.
- **Efficiency:** With the [fzf](https://github.com/junegunn/fzf) fuzzy finder, `pw` allows for rapid and intuitive interaction with your keychains - nice!
- **Simplicity:** `pw` is built using simple bash, making it easy to understand, modify, and extend.
- **Extensibility:** Adding plugins for your preferred password managers takes only minutes (see [plugins](src/plugins)).
- **Clipboard Management:** Automatically clears passwords from the clipboard after a specified duration.
- **Multiple Keychain Support**: Effortlessly manage and switch between [multiple keychains](#example-using-multiple-keychains) stored in various locations.

![pw-fzf](readme/pw-fzf.png)

# Install pw and fzf

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sschmid/pw/main/install)"
brew install fzf
```

# Uninstall pw and fzf

```bash
/usr/local/opt/pw/install --uninstall
brew uninstall fzf
```

# Usage

```
$ pw --help
██████╗ ██╗    ██╗
██╔══██╗██║    ██║
██████╔╝██║ █╗ ██║
██╔═══╝ ██║███╗██║
██║     ╚███╔███╔╝
╚═╝      ╚══╝╚══╝

usage: pw [--help | -h]
          [-p] [-k <keychain>] [<commands>]

options:
  -p              print password instead of copying
  -k <keychain>   use given keychain

commands:
  [-p] no command             copy (or print) password using fuzzy finder
  [-p] <name> [<account>]     copy (or print) password
  init <keychain>             create keychain
  add <name> [<account>]      add entry (leave password empty to generate one)
  edit [<name>] [<account>]   edit entry (leave password empty to generate one)
  rm [<name>] [<account>]     remove entry
  ls                          list all entries
  gen                         generate password
  open                        open keychain in native gui
  lock                        lock keychain
  unlock                      unlock keychain
  update                      update pw

customization:
  PW_KEYCHAIN                 keychain to use when not specified with -k (default: login.keychain-db)
  PW_GEN_LENGTH               length of generated passwords (default: 35)
  PW_CLIP_TIME                time in seconds after which the password is cleared from the clipboard (default: 45)
  PW_RC                       path to the configuration file (default: ~/.pwrc)
```

# Example: Adding entries and copying passwords

```
$ pw add github                   # add new entry for github
Enter password for github:
Retype password for github:

$ pw github                       # copy password for github

$ pw add slack me@work.com        # add new entry for slack with account
Enter password for slack:         # leave empty to generate a password

$ pw                              # open fzf and copy password for selected entry
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   github                                          login.keychain-db          │
│ > slack                   me@work.com             login.keychain-db          │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# Example: Specifying a keychain

There are multiple ways to specify a keychain:

```bash
# specify keychain using -k for the current command (overrides PW_KEYCHAIN)
pw -k secrets.keychain-db
```

```bash
# specify keychain for the current command
PW_KEYCHAIN=secrets.keychain-db pw
```

```bash
# export default keychain for the current shell
export PW_KEYCHAIN=secrets.keychain-db
pw
```

```
$ pw init secrets.keychain-db

$ pw -k secrets.keychain-db add twitter s_schmid
Enter password for twitter:

$ pw -k secrets.keychain-db -p
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│ > twitter                 s_schmid                secrets.keychain-db        │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# Example: Using multiple keychains

`pw` allows you to interact with multiple keychains from different password
managers. This feature is particularly useful when you have keychains stored
in various locations. You can specify different keychains using the `PW_RC`
configuration file, which defaults to `~/.pwrc`.

By default, `pw` uses the keychain specified in the `PW_KEYCHAIN` variable.
However, you can define multiple keychains in the `PW_KEYCHAINS` array
within the `~/.pwrc` configuration file. Here's an example of how the
default `~/.pwrc` file looks:

```bash
PW_KEYCHAINS=(login.keychain-db)
```

To use multiple keychains, modify the `PW_KEYCHAINS` array to include
the paths to your desired keychains, e.g.:

```bash
PW_KEYCHAINS=(
  login.keychain-db
  secrets.keychain-db
  ~/path/to/keepassxc.kdbx
  ~/path/to/myproject.keychain-db
)
```

After configuring your keychains, continue using `pw` as usual. If no keychain
is specified with `-k` or by setting `PW_KEYCHAIN`, `pw` allows you to select
one from `PW_KEYCHAINS` using the fuzzy finder.

![pw-fzf](readme/pw-dbs.png)

# Example: Using `pw` in a command or script
Use `pw` to avoid leaking secrets in scripts that you share or commit.

```bash
curl -s -H "Authorization: token $(pw -p GITHUB_TOKEN)" https://api.github.com/user
```

# Customization

Export or provide the following variables to customize pw's default behaviour:

```bash
# Default keychain used when not specified with -k
# otherwise, PW_KEYCHAINS is used to select a keychain
export PW_KEYCHAIN=secrets.keychain-db

# Generated password length
export PW_GEN_LENGTH=35

# Time after which the password is cleared from the clipboard
export PW_CLIP_TIME=45

# Path to the configuration file
export PW_RC=~/.mypwrc
```

Configure keychains in `~/.pwrc`

```bash
PW_KEYCHAINS=(
  login.keychain-db
  secrets.keychain-db
  ~/path/to/keepassxc.kdbx
  ~/path/to/myproject.keychain-db
)
```

# Dependencies
- [fzf](https://github.com/junegunn/fzf)
