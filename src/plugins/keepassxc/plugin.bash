if ! command -v keepassxc-cli > /dev/null; then
  cat << EOF >&2
command not found: keepassxc-cli
Please make sure that KeePassXC is installed and keepassxc-cli is in your PATH.
EOF
  exit 1
fi

_keepassxc-cli_with_metadata() {
  local command="$1"; shift
  local -a options=()
  if [[ -n "$PW_KEYCHAIN_METADATA" ]]; then
    local IFS=, key value
    for pair in ${PW_KEYCHAIN_METADATA}; do
      key="${pair%%=*}"
      value="${pair#*=}"
      [[ "${key}" == "yubikey" ]] && options+=("--yubikey" "${value}")
    done
  else
    options+=("--quiet")
  fi
  keepassxc-cli "${command}" "${options[@]}" "$@"
}

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
    keepassxc-cli db-create --quiet --set-password "${PW_KEYCHAIN}" << EOF
${password}
${password}
EOF
  else
    keepassxc-cli db-create --set-password "${PW_KEYCHAIN}"
  fi
}

pw::plugin_add() {
  _keepassxc-cli_with_metadata add --password-prompt "${PW_KEYCHAIN}" ${2:+-u "$2"} "$1" << EOF
${PW_KEEPASSXC_PASSWORD}
$3
EOF
}

pw::plugin_edit() {
  _keepassxc-cli_with_metadata edit --password-prompt "${PW_KEYCHAIN}" "$1" << EOF
${PW_KEEPASSXC_PASSWORD}
$3
EOF
}

pw::plugin_get() {
  _keepassxc-cli_with_metadata show --show-protected --attributes password "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_rm() {
  _keepassxc-cli_with_metadata rm "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_ls() {
  local format="${1:-default}" list
  if ! list="$(_keepassxc-cli_with_metadata ls --flatten --recursive "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}" \
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

pw::plugin_fzf_preview() {
  local -i can_preview=1
  if [[ -v PW_KEYCHAIN_METADATA ]]; then
    local IFS=, key value
    for pair in ${PW_KEYCHAIN_METADATA}; do
      key="${pair%%=*}"
      value="${pair#*=}"
      [[ "${key}" == "yubikey" ]] && can_preview=0
    done
  fi

  if ((can_preview))
  then echo "keepassxc-cli show --quiet \"${PW_KEYCHAIN}\" {3} <<< \"${PW_KEEPASSXC_PASSWORD}\""
  else echo "echo 'Preview not available with YubiKey'"
  fi
}

pw::plugin_open() {
  open -a "KeePassXC" "${PW_KEYCHAIN}"
}

pw::plugin_lock() {
  echo "not available for keepassxc"
}

pw::plugin_unlock() {
  _keepassxc-cli_with_metadata open "${PW_KEYCHAIN}"
}
