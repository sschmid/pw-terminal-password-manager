# 🔐 pw - password manager using macOS keychain

pw is a one-file bash wrapper for the [macOS keychain](https://developer.apple.com/documentation/security/keychain_services) [security](https://ss64.com/osx/security.html) commands to make interacting with the keychain fast, easy and secure. It's combining the security of the macOS keychain with the speed and simplicity of the [fzf](https://github.com/junegunn/fzf) fuzzy finder.

[![Tests](https://github.com/sschmid/pw/actions/workflows/tests.yaml/badge.svg)](https://github.com/sschmid/pw/actions/workflows/tests.yaml)
[![Twitter @s_schmid](https://img.shields.io/badge/twitter-follow%20%40s__schmid-blue.svg)](https://twitter.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fsschmid%2Fpw&screen_name=s_schmid&tw_p=followbutton)
[![Latest release](https://img.shields.io/github/release/sschmid/pw.svg)](https://github.com/sschmid/pw/releases)

```
$ pw
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   ios.password            me@work.com             login.keychain             │
│   ios.user                me@work.com             login.keychain             │
│ > github                  sschmid                 login.keychain             │
│   github.token            sschmid                 login.keychain             │
│   nuget                   sschmid                 login.keychain             │
│   slack                   me@work.com             login.keychain             │
│   twitter                 s_schmid                login.keychain             │
│   unity                   me@work.com             login.keychain             │
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
$ pw help
██████╗ ██╗    ██╗
██╔══██╗██║    ██║
██████╔╝██║ █╗ ██║
██╔═══╝ ██║███╗██║
██║     ╚███╔███╔╝
╚═╝      ╚══╝╚══╝

usage: pw [-p] [-a | -k <keychain>] [<commands>]

options:
  -p              print password instead of copying
  -a              search in all user keychains
  -k <keychain>   search in given keychain

commands:
  [-p] no command             copy (or print) password using fuzzy finder
  [-p] <name> [<account>]     copy (or print) password
  init                        create keychain (default: login.keychain)
  open                        open keychain in Keychain Access
  lock                        lock keychain
  unlock                      unlock keychain
  add <name> [<account>]      add entry (leave password empty to generate one)
  edit [<name>] [<account>]   edit entry (leave password empty to generate one)
  rm [<name>] [<account>]     remove entry
  ls                          list all entries
  update                      update pw
  help                        show this
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
│   github                                          login.keychain             │
│ > slack                   me@work.com             login.keychain             │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# example with custom keychain
`pw -k <keychain>` sets the keychain for the current command.
Export `PW_KEYCHAIN` to change the default keychain.

```bash
export PW_KEYCHAIN=secrets.keychain
```

```
$ pw -k secrets init
$ pw -k secrets add twitter s_schmid
Enter password for twitter:
$ pw -p -k secrets    # -p prints password instead of copying
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│ > twitter                 s_schmid                secrets.keychain           │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
$ pw -a     # -a searches in all user keychains
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│ > github                                          login.keychain             │
│   slack                   me@work.com             login.keychain             │
│   twitter                 s_schmid                secrets.keychain           │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# example in other script
Use `pw` to avoid leaking secrets in scripts that you share or commit.

```bash
github::me() {
  local token
  token="$(pw -p github.token)"
  curl -s -H "Authorization: token ${token}" "https://api.github.com/user"
}
```

## dependencies
- [fzf](https://github.com/junegunn/fzf)
