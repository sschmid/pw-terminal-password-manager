filetype() { echo "Mac OS X Keychain File"; }

register() {
  [[ -f "${PW_KEYCHAIN}" && "$(file -b "${PW_KEYCHAIN}")" == "Mac OS X Keychain File" ]] && return 0
  [[ -f "${HOME}/Library/Keychains/${PW_KEYCHAIN}" ]] && return 0
  return 1
}
