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

### set default keychain (default: pw.keychain)

```bash
export PW_KEYCHAIN=login.keychain
```

## dependencies
- [fzf](https://github.com/junegunn/fzf)
