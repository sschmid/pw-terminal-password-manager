filetype() { echo "Keepass password database 2.x KDBX"; }

register() {
  [[ -f "${PW_KEYCHAIN}" && "$(file -b "${PW_KEYCHAIN}")" == "Keepass password database 2.x KDBX" ]] && return 0
  return 1
}
