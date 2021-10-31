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
```

# example

```
$ pw init
$ pw add github
Enter password for github:
Retype password for github:
$ pw github
github123
$ pw add github me@work.com
Enter password for github:         # leave empty to generate a password
$ pw
╭──────────────────────────────────────────────────────────────────────────────╮
│ >                                                                            │
│   github                                          pw.keychain                │
│ > github                  me@work.com             pw.keychain                │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
3<w>q]tM[?D+7tjLLDlvg>OE.3$X6n=y)
$
```

### set default keychain (default: pw.keychain)

```bash
export PW_KEYCHAIN=login.keychain
```

## dependencies
- [fzf](https://github.com/junegunn/fzf)
