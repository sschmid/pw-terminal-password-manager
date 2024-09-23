# shellcheck disable=SC2034
FILE_TYPE="PGP"
FILE_EXTENSION="/, gpg, asc"

pw::discover_keychains() { :; }

pw::register() {
  [[ -d "${PW_KEYCHAIN}" ]]
}

pw::register_with_extension() {
  [[ "$1" == */ ]]
}
