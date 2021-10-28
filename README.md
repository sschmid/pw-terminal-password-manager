# pw - macOS command line password manager using macOS keychain

[![Twitter @s_schmid](https://img.shields.io/badge/twitter-follow%20%40s__schmid-blue.svg)](https://twitter.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fsschmid%pw&screen_name=s_schmid&tw_p=followbutton)
[![Latest release](https://img.shields.io/github/release/sschmid/pw.svg)](https://github.com/sschmid/pw/releases)

# install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sschmid/pw/main/install)"
```

# setup

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
## usage

```
usage: pw
  <nothing>                search entry and copy password
  <entry>                  print password for entry
  init [<keychain>]        create keychain (default: pw.keychain)
  add <name> [<account>]   add entry
  rm <name> [<account>]    remove entry
  ls                       list all entries
  update                   update pw
```
## dependencies
- [fzf](https://github.com/junegunn/fzf)
