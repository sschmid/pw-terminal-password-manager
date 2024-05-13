# 🔐 pw - use multiple trusted password managers with the speed and simplicity of fzf

Originally, `pw` started as a single-file bash wrapper for [macOS keychain's](https://developer.apple.com/documentation/security/keychain_services) [security](https://ss64.com/osx/security.html) commands, aimed at making interactions fast, easy, and secure.

Now, `pw` has evolved to support plugins, enabling integration with other password managers like [KeePassXC](https://keepassxc.org).

`pw` combines the security of already trusted password managers with the speed and simplicity of the [fzf](https://github.com/junegunn/fzf) fuzzy finder. It allows you to interact with multiple password managers conveniently in one place.

[![Tests](https://github.com/sschmid/pw/actions/workflows/tests.yaml/badge.svg)](https://github.com/sschmid/pw/actions/workflows/tests.yaml)
[![Twitter @s_schmid](https://img.shields.io/badge/twitter-follow%20%40s__schmid-blue.svg)](https://twitter.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fsschmid%2Fpw&screen_name=s_schmid&tw_p=followbutton)
[![Latest release](https://img.shields.io/github/release/sschmid/pw.svg)](https://github.com/sschmid/pw/releases)

```
$ pw
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   ios.password            me@work.com             login.keychain-db          │
│   ios.user                me@work.com             login.keychain-db          │
│ > github                  sschmid                 login.keychain-db          │
│   github.token            sschmid                 login.keychain-db          │
│   nuget                   sschmid                 login.keychain-db          │
│   slack                   me@work.com             login.keychain-db          │
│   twitter                 s_schmid                login.keychain-db          │
│   unity                   me@work.com             login.keychain-db          │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# install pw

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sschmid/pw/main/install)"
````

# install [fzf](https://github.com/junegunn/fzf) (command-line fuzzy finder)

```bash
brew install fzf
```

# usage

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

# example

```
$ pw add github                # add new entry for github
Enter password for github:
Retype password for github:
$ pw github                    # copy password for github
$ pw add slack me@work.com     # add new entry for slack with account
Enter password for slack:      # leave empty to generate a password
$ pw                           # open fzf and copy password for selected entry
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   github                                          login.keychain-db          │
│ > slack                   me@work.com             login.keychain-db          │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# example with custom keychain
`pw -k <keychain>` sets the keychain for the current command.
Export `PW_KEYCHAIN` to change the default keychain.

```bash
export PW_KEYCHAIN=secrets.keychain-db
```

```
$ pw init secrets.keychain-db
$ pw add twitter s_schmid
Enter password for twitter:
$ pw -p
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│ > twitter                 s_schmid                secrets.keychain-db        │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# example with multiple keychains
`pw` allows you to use multiple keychains from different password managers. This feature is particularly useful when you have keychains stored in various locations. You can specify different keychains using the `PW_RC` configuration file, which defaults to `~/.pwrc`.

By default, `pw` uses the keychain specified in the `PW_KEYCHAIN` variable. However, you can define multiple keychains in the `PW_KEYCHAINS` array within the `~/.pwrc` configuration file. Here's an example of how the default `~/.pwrc` file looks:

```bash
PW_KEYCHAINS=(login.keychain-db)
```

To use multiple keychains, modify the `PW_KEYCHAINS` array to include the paths to your desired keychains, e.g.:

```bash
PW_KEYCHAINS=(
  login.keychain-db
  secrets.keychain-db
  ~/path/to/keepassxc.kdbx
  ~/path/to/myproject.keychain-db
)
```

After configuring your keychains, continue using `pw` as usual. If no keychain is specified with `-k` or by setting `PW_KEYCHAIN`, `pw` allows you to select one from `PW_KEYCHAINS` using the fuzzy finder.

```bash
$ pw
╭──────────────────────────────────────────────────────────────────────────────╮
│ db>                                                                          │
│ > login.keychain-db                                                          │
│   secrets.keychain-db                                                        │
│   ~/path/to/keepassxc.kdbx                                                   │
│   ~/path/to/myproject.keychain-db                                            │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# example for using `pw` in an other script
Use `pw` to avoid leaking secrets in scripts that you share or commit.

```bash
github::me() {
  curl -s -H "Authorization: token $(pw -p github.token)" "https://api.github.com/user"
}
```

# customization

Export or provide the following variables to customize pw's default behaviour:

```bash
# Default keychain used when not specified with -k
export PW_KEYCHAIN=secrets.keychain-db

# Generated password length
export PW_GEN_LENGTH=35

# Time after which the password is cleared from the clipboard
export PW_CLIP_TIME=45
```

specify multiple keychains in `~/.pwrc`

```bash
PW_KEYCHAINS=(
  login.keychain-db
  secrets.keychain-db
  ~/path/to/keepassxc.kdbx
  ~/path/to/myproject.keychain-db
)
```

# dependencies
- [fzf](https://github.com/junegunn/fzf)
