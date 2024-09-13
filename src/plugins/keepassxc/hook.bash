FILE_TYPE="Keepass password database 2.x KDBX"
FILE_EXTENSION="kdbx"

pw::register() {
  [[ -f "${PW_KEYCHAIN}" ]]
  [[ "$(file -b "${PW_KEYCHAIN}")" == "${FILE_TYPE}" ]]
}

pw::register_with_extension() {
  [[ "$1" == "${FILE_EXTENSION}" ]]
}
