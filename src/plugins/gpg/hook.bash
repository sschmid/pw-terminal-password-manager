# shellcheck disable=SC2034
FILE_TYPE="PGP"
FILE_EXTENSION="/, gpg, asc"

pw::discover_keychains() {
  local filetype
  while read -r path; do
    filetype="$(file -b "${path}")"
    # .asc
    [[ "${filetype}" != "${FILE_TYPE}"* ]] || echo "$(dirname "${path}")/"
    # .gpg
    [[ "${filetype}" != "data" ]] || echo "$(dirname "${path}")/"
  done < <(find "${PWD}" -type f -maxdepth 1)
}

pw::register() {
  [[ -d "${PW_KEYCHAIN}" ]]
}

pw::register_with_extension() {
  [[ "$1" == */ ]]
}
