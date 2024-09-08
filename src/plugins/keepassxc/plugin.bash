if ! command -v keepassxc-cli > /dev/null; then
  cat << EOF >&2
command not found: keepassxc-cli
Please make sure that KeePassXC is installed and the keepassxc-cli is in your PATH.
EOF
  exit 1
fi

pw::prepare_keychain() {
  if [[ ! -v PW_KEEPASSXC_PASSWORD ]]; then
    if [[ -p /dev/stdin ]]; then
      IFS= read -r PW_KEEPASSXC_PASSWORD
    else
      read -rsp "Enter password to unlock ${PW_KEYCHAIN}:"$'\n' PW_KEEPASSXC_PASSWORD </dev/tty
    fi
  fi
}

pw::plugin_init() {
  if [[ -p /dev/stdin ]]; then
    IFS= read -r password
    keepassxc-cli db-create -qp "${PW_KEYCHAIN}" << EOF
${password}
${password}
EOF
  else
    keepassxc-cli db-create -p "${PW_KEYCHAIN}"
  fi
}

pw::plugin_add() {
  keepassxc-cli add -qp "${PW_KEYCHAIN}" ${2:+-u "$2"} "$1" << EOF
${PW_KEEPASSXC_PASSWORD}
$3
EOF
}

pw::plugin_edit() {
  keepassxc-cli edit -qp "${PW_KEYCHAIN}" "$1" << EOF
${PW_KEEPASSXC_PASSWORD}
$3
EOF
}

pw::plugin_get() {
  keepassxc-cli show -qsa password "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_rm() {
  keepassxc-cli rm -q "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_ls() {
  local format="${1:-default}" list
  if ! list="$(keepassxc-cli ls -qfR "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}" \
    | { grep -v -e '/$' -e 'Recycle Bin/' || true; } \
    | LC_ALL=C sort)"
  then
    echo "Error while reading the database ${PW_KEYCHAIN}: Invalid credentials were provided, please try again." >&2
    exit 1
  fi

  if [[ "${list}" != "[empty]" ]]; then
    case "${format}" in
      fzf) echo "${list}" | awk '{print $0 "\t\t" $0}' ;;
      *) echo "${list}" ;;
    esac
  fi
}

pw::plugin_open() {
  open -a "KeePassXC" "${PW_KEYCHAIN}"
}

pw::plugin_lock() {
  echo "not available for keepassxc"
}

pw::plugin_unlock() {
  keepassxc-cli open "${PW_KEYCHAIN}"
}
