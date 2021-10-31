# 🔐 pw - password manager using macOS keychain

pw is a one-file bash wrapper for the [macOS keychain](https://developer.apple.com/documentation/security/keychain_services) [security](https://ss64.com/osx/security.html) commands to make interacting with the keychain fast, easy and secure. It's combining the security of the macOS keychain with the speed and simplicity of the [fzf](https://github.com/junegunn/fzf) fuzzy finder.

[![Twitter @s_schmid](https://img.shields.io/badge/twitter-follow%20%40s__schmid-blue.svg)](https://twitter.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fsschmid%2Fpw&screen_name=s_schmid&tw_p=followbutton)
[![Latest release](https://img.shields.io/github/release/sschmid/pw.svg)](https://github.com/sschmid/pw/releases)

```
$ pw
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   GITHUB_ACCESS_TOKEN     repo                    pw.keychain                │
│   IOS_PASSWORD            me@work.com             pw.keychain                │
│   IOS_USER                me@work.com             pw.keychain                │
│ > github                  sschmid                 pw.keychain                │
│   nuget                   sschmid                 pw.keychain                │
│   slack                   me@work.com             pw.keychain                │
│   twitter                 s_schmid                pw.keychain                │
│   unity                   me@work.com             pw.keychain                │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# install

```bash
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/sschmid/pw/main/install)"

# install fzf
$ brew install fzf
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

usage: pw [-c] [-a | -k <keychain>] [<commands>]

options:
  -c              copy password instead of printing
  -a              search in all user keychains
  -k <keychain>   search in given keychain

commands:
  [-c] no command           print (or copy) password using fuzzy finder
  [-c] <name> [<account>]   print (or copy) password
  init                      create keychain (default: pw.keychain)
  open                      open keychain in Keychain Access
  lock                      lock keychain
  unlock                    unlock keychain
  add <name> [<account>]    add entry (leave password empty to generate one)
  rm                        remove entry using fuzzy finder
  rm <name> [<account>]     remove entry
  ls                        list all entries
  update                    update pw
  help                      show this
```

# example

```
$ pw init                      # create keychain (default: pw.keychain)
$ pw add github                # add new entry for github
Enter password for github:
Retype password for github:
$ pw github                    # print password for github
github123
$ pw add slack me@work.com     # add new entry for slack with account
Enter password for slack:      # leave empty to generate a password
$ pw                           # open fzf and print password for selected entry
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   github                                          pw.keychain                │
│ > slack                   me@work.com             pw.keychain                │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
3<w>q]tM[?D+7tjLLDlvg>OE.3$X6n=y)
```

# example with custom keychain
`pw -k <keychain>` sets the keychain for the current command.
Export `PW_KEYCHAIN` to change the default keychain.

```bash
export PW_KEYCHAIN=login.keychain
```

```
$ pw -k secrets init
$ pw -k secrets add twitter s_schmid
Enter password for twitter:
$ pw -c -k secrets    # -c copies password to clipboard instead of printing
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
│ > github                                          pw.keychain                │
│   slack                   me@work.com             pw.keychain                │
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
  token="$(pw GITHUB_ACCESS_TOKEN)"
  curl -s -H "Authorization: token ${token}" "https://api.github.com/user"
}
```

## dependencies
- [fzf](https://github.com/junegunn/fzf)
