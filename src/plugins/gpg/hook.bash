# shellcheck disable=SC2034
FILE_TYPE="PGP"
FILE_EXTENSION="/, gpg, asc"

register() {
  [[ -d "${PW_KEYCHAIN}" ]]
}

register_with_extension() {
  [[ "$1" == */ ]]
}
