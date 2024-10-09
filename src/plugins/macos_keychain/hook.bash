FILE_TYPE="Mac OS X Keychain File"
FILE_EXTENSION="keychain-db"

pw::discover_keychains() {
  local filetype
  while read -r path; do
    filetype="$(file -b "${path}")"
    [[ "${filetype}" != "${FILE_TYPE}" ]] || echo "${path}"
  done < <(find "${PWD}" -type f -maxdepth 1)
}

pw::register() {
  [[ -f "${PW_KEYCHAIN}" && "$(file -b "${PW_KEYCHAIN}")" == "${FILE_TYPE}" ]] && return 0
  [[ -f "${HOME}/Library/Keychains/${PW_KEYCHAIN}" ]]
}

pw::register_with_extension() {
  [[ "$1" == "${FILE_EXTENSION}" ]]
}
