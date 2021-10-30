# pw - password manager using macOS keychain

pw is a one-file bash wrapper for the [macOS keychain](https://developer.apple.com/documentation/security/keychain_services) [security](https://ss64.com/osx/security.html) commands to make interacting with the keychain fast, easy and secure. It's combining the security of the macOS keychain with the speed and simplicity of the [fzf](https://github.com/junegunn/fzf) fuzzy finder.

[![Twitter @s_schmid](https://img.shields.io/badge/twitter-follow%20%40s__schmid-blue.svg)](https://twitter.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fsschmid%pw&screen_name=s_schmid&tw_p=followbutton)
[![Latest release](https://img.shields.io/github/release/sschmid/pw.svg)](https://github.com/sschmid/pw/releases)

```
$ pw
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   GITHUB_ACCESS_TOKEN     sschmid                 pw.keychain                │
│   twitter                 sschmid                 pw.keychain                │
│   nuget                   sschmid                 pw.keychain                │
│ > github                  sschmid                 pw.keychain                │
│   slack                   sschmid                 pw.keychain                │
│   unity                   sschmid                 pw.keychain                │
│   IOS_USER                popcore                 pw.keychain                │
│   IOS_PASSWORD            popcore                 pw.keychain                │
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

# example

```
$ pw init
$ pw add github.com
Enter password for github.com:
Retype password for github.com:
$ pw github.com
github123
$ pw add github.com work
Enter password for github.com:
Retype password for github.com:
$ pw
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│ > github.com    sschmid                                                      │
│   github.com    work                                                         │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
```

# usage

### `pw init [<keychain>] - create keychain (default: pw.keychain)`

```
$ pw init                    # create default keychain at ~/Library/Keychains/pw.keychain-db
$ pw init secrets.keychain   # create custom keychain at ~/Library/Keychains/secrets.keychain-db
```

### `pw open [<keychain>] - open keychain in Keychain Access`

```
$ pw open                    # open default keychain
$ pw open secrets.keychain   # open custom keychain
```

### `pw lock [<keychain>] - lock keychain`

```
$ pw lock                    # lock default keychain
$ pw lock secrets.keychain   # lock custom keychain
```

### `pw unlock [<keychain>] - unlock keychain`

```
$ pw unlock                           # unlock default keychain
$ pw unlock secrets.keychain          # unlock custom keychain
```

### `pw add <name> [<account> <keychain>] - add entry`

```
$ pw add github.com                            # add entry with default account ($USER)
$ pw add github.com sschmid                    # add entry with custom account
$ pw add github.com sschmid secrets.keychain   # add entry with custom account in given keychain
```

### `pw [-a] rm <name> [<account> <keychain>] - remove entry`

```
$ pw rm github.com                            # remove entry matching default account ($USER)
$ pw rm github.com sschmid                    # remove entry matching custom account
$ pw rm github.com sschmid secrets.keychain   # remove entry matching custom account in given keychain
$ pw rm                                       # do fuzzy search using fzf and remove entry
$ pw -a rm                                    # do fuzzy search in all user keychains and remove entry
```

### `pw [-a | -k <keychain>] [<name> <account> <keychain>] - get password for entry`

```
$ pw                                       # do fuzzy search using fzf and copy password to clipboard
$ pw -k secrets.keychain                   # do fuzzy search in given keychain and copy password to clipboard
$ pw -a                                    # do fuzzy search in all user keychains and copy password to clipboard
$ pw github.com                            # print password matching default account ($USER)
$ pw github.com sschmid                    # print password matching custom account
$ pw github.com sschmid secrets.keychain   # print password matching custom account in given keychain
```

### `pw ls [<keychain>] - list all entries`

```
$ pw ls                    # list all entries in default keychain
$ pw ls secrets.keychain   # list all entries in given keychain
$ pw -a ls                 # list all entries in all user keychains
```

### `pw update - update pw`

```
$ pw update
```

### set default keychain (default: pw.keychain)

```bash
export PW_KEYCHAIN=login.keychain
```

## dependencies
- [fzf](https://github.com/junegunn/fzf)
