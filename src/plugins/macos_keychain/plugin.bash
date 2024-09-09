pw::prepare_keychain() {
  : # this plugin does not require any preparation
}

pw::plugin_init() {
  if [[ -p /dev/stdin ]]; then
    IFS= read -r password
    security create-keychain -p "${password}" "${PW_KEYCHAIN}"
  else
    security create-keychain "${PW_KEYCHAIN}"
  fi
}

pw::plugin_add() {
  security add-generic-password -s "$1" -a "$2" -w "$3" "${PW_KEYCHAIN}"
}

pw::plugin_edit() {
  security add-generic-password -U -s "$1" -a "$2" -w "$3" "${PW_KEYCHAIN}"
}

pw::plugin_get() {
  security find-generic-password ${1:+-s "$1"} ${2:+-a "$2"} -w "${PW_KEYCHAIN}"
}

pw::plugin_rm() {
  security delete-generic-password ${1:+-s "$1"} ${2:+-a "$2"} "${PW_KEYCHAIN}" > /dev/null
}

pw::plugin_ls() {
  local format="${1:-default}"
  case "${format}" in
    fzf)
      security dump-keychain "${PW_KEYCHAIN}" | awk '
        BEGIN { FS="<blob>="; }
        /"acct"/ {
          account = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2)
        }
        /"svce"/ {
          name = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2)
          printf "%-40s\t%s\t%s\t%s\n", name, account, name, account
        }' | LC_ALL=C sort
      ;;
    *)
      security dump-keychain "${PW_KEYCHAIN}" | awk '
        BEGIN { FS="<blob>="; }
        /"acct"/ {
          account = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2)
        }
        /"svce"/ {
          name = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2)
          printf "%-40s\t%s\n", name, account
        }' | LC_ALL=C sort
      ;;
  esac
}

pw::plugin_fzf_preview() {
  : # this plugin does not implement fzf preview
}

pw::plugin_open() {
  if [[ -f "${PW_KEYCHAIN}" ]]; then
    open -a "Keychain Access" "${PW_KEYCHAIN}"
  elif [[ -f "${HOME}/Library/Keychains/${PW_KEYCHAIN}" ]]; then
    open -a "Keychain Access" "${HOME}/Library/Keychains/${PW_KEYCHAIN}"
  fi
}

pw::plugin_lock() {
  security lock-keychain "${PW_KEYCHAIN}"
}

pw::plugin_unlock() {
  if [[ -p /dev/stdin ]]; then
    IFS= read -r password
    security unlock-keychain -p "${password}" "${PW_KEYCHAIN}"
  else
    security unlock-keychain "${PW_KEYCHAIN}"
  fi
}
