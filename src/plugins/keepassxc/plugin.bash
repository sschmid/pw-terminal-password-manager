if ! command -v keepassxc-cli > /dev/null; then
  cat << EOF >&2
command not found: keepassxc-cli
Please make sure that KeePassXC is installed and keepassxc-cli is in your PATH.
EOF
  exit 1
fi

_keepassxc-cli_with_args() {
  local command="$1"; shift
  local -a options=()
  local -i quiet=1
  [[ -v PW_KEYCHAIN_ARGS["yubikey"] ]] && options+=("--yubikey" "${PW_KEYCHAIN_ARGS["yubikey"]}") && quiet=0
  [[ -v PW_KEYCHAIN_ARGS["keyfile"] ]] && options+=("--key-file" "${PW_KEYCHAIN_ARGS["keyfile"]}")
  [[ "${command}" == "open" ]] && quiet=0
  ((quiet)) && options+=("--quiet")
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
  local -a options=()
  [[ -v PW_KEYCHAIN_ARGS["keyfile"] ]] && options+=("--set-key-file" "${PW_KEYCHAIN_ARGS["keyfile"]}")
  if [[ -p /dev/stdin ]]; then
    IFS= read -r password
    keepassxc-cli db-create --quiet "${options[@]}" --set-password "${PW_KEYCHAIN}" << EOF
${password}
${password}
EOF
  else
    keepassxc-cli db-create "${options[@]}" --set-password "${PW_KEYCHAIN}"
  fi
}

pw::plugin_add() {
  _keepassxc-cli_with_args add --password-prompt "${PW_KEYCHAIN}" \
    ${PW_ACCOUNT:+--username "${PW_ACCOUNT}"} \
    ${PW_URL:+--url "${PW_URL}"} \
    ${PW_NOTES:+--notes "${PW_NOTES}"} \
    "${PW_NAME}" << EOF
${PW_KEEPASSXC_PASSWORD}
${PW_PASSWORD}
EOF
}

pw::plugin_edit() {
  _keepassxc-cli_with_args edit --password-prompt "${PW_KEYCHAIN}" "${PW_NAME}" << EOF
${PW_KEEPASSXC_PASSWORD}
${PW_PASSWORD}
EOF
}

pw::plugin_get() {
  _keepassxc-cli_with_args show --show-protected --attributes password "${PW_KEYCHAIN}" "${PW_NAME}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_rm() {
  _keepassxc-cli_with_args rm "${PW_KEYCHAIN}" "${PW_NAME}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_ls() {
  local format="${1:-default}" list
  if ! list="$(_keepassxc-cli_with_args ls --flatten --recursive "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}" \
    | { grep -v -e '/$' -e 'Recycle Bin/' || true; } \
    | LC_ALL=C sort)"
  then
    echo "Error while reading the database ${PW_KEYCHAIN}: Invalid credentials were provided, please try again." >&2
    exit 1
  fi

  if [[ "${list}" != "[empty]" ]]; then
    case "${format}" in
      fzf) echo "${list}" | awk '{print $0 "\t\t\t" $0}' ;;
      *) echo "${list}" ;;
    esac
  fi
}

pw::plugin_fzf_preview() {
  if [[ -v PW_KEYCHAIN_ARGS["yubikey"] ]]
  then echo "echo 'Preview not available with YubiKey'"
  else echo "keepassxc-cli show --quiet \"${PW_KEYCHAIN}\" {4} <<< \"${PW_KEEPASSXC_PASSWORD}\""
  fi
}

pw::plugin_open() {
  open -a "KeePassXC" "${PW_KEYCHAIN}"
}

pw::plugin_lock() {
  echo "not available for keepassxc"
}

pw::plugin_unlock() {
  _keepassxc-cli_with_args open "${PW_KEYCHAIN}"
}
