FILE_TYPE="Mac OS X Keychain File"
FILE_EXTENSION="keychain-db"

register() {
  [[ -f "${PW_KEYCHAIN}" && "$(file -b "${PW_KEYCHAIN}")" == "${FILE_TYPE}" ]] && return 0
  [[ -f "${HOME}/Library/Keychains/${PW_KEYCHAIN}" ]]
}

register_with_extension() {
  [[ "$1" == "${FILE_EXTENSION}" ]]
}
