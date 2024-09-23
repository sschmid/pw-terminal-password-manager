FILE_TYPE="Keepass password database 2.x KDBX"
FILE_EXTENSION="kdbx"

pw::discover_keychains() {
  local filetype
  while read -r path; do
    filetype="$(file -b "${path}")"
    [[ "${filetype}" != "${FILE_TYPE}" ]] || echo "${path}"
  done < <(find . -type f -maxdepth 1)
}

pw::register() {
  [[ -f "${PW_KEYCHAIN}" ]]
  [[ "$(file -b "${PW_KEYCHAIN}")" == "${FILE_TYPE}" ]]
}

pw::register_with_extension() {
  [[ "$1" == "${FILE_EXTENSION}" ]]
}
