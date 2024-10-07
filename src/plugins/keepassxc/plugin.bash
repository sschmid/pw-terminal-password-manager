command -v keepassxc-cli >/dev/null || pw::exit \
  "command not found: keepassxc-cli" \
  "Please make sure that KeePassXC is installed and keepassxc-cli is in your PATH."

_keepassxc-cli_with_args() {
  local command="$1"; shift
  local -a options=()
  local -i quiet=1
  [[ -v PW_KEYCHAIN_ARGS["yubikey"] ]] && options+=("--yubikey" "${PW_KEYCHAIN_ARGS["yubikey"]}") && quiet=0
  [[ -v PW_KEYCHAIN_ARGS["keyfile"] ]] && options+=("--key-file" "${PW_KEYCHAIN_ARGS["keyfile"]}")
  [[ "${command}" == "open" ]] && quiet=0
  (( quiet )) && options+=("--quiet")
  keepassxc-cli "${command}" "${options[@]}" "$@"
}

pw::prepare_keychain() {
  if [[ ! -v PW_KEEPASSXC_PASSWORD ]]; then
    if [[ -p /dev/stdin ]]; then
      IFS= read -r PW_KEEPASSXC_PASSWORD
    else
      IFS= read -rsp "Enter password to unlock ${PW_KEYCHAIN}:"$'\n' PW_KEEPASSXC_PASSWORD </dev/tty
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

_iterate_dirs() {
  local IFS=/ path=""
  for dir in ${PW_NAME}; do
    path+="${dir}/"
    echo "${path}"
  done
}

pw::plugin_add() {
  mapfile -t dirs < <(_iterate_dirs)
  for (( i = 0; i < ${#dirs[@]} - 1; i++ )); do
    _keepassxc-cli_with_args mkdir "${PW_KEYCHAIN}" "${dirs[i]::-1}" <<< "${PW_KEEPASSXC_PASSWORD}" &>/dev/null || true
  done

  _keepassxc-cli_with_args add --password-prompt "${PW_KEYCHAIN}" ${PW_ACCOUNT:+--username "${PW_ACCOUNT}"} ${PW_URL:+--url "${PW_URL}"} ${PW_NOTES:+--notes "${PW_NOTES}"} "${PW_NAME}" << EOF
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

pw::plugin_show() {
  _keepassxc-cli_with_args show "${PW_KEYCHAIN}" "${PW_NAME}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_rm() {
  _keepassxc-cli_with_args rm "${PW_KEYCHAIN}" "${PW_NAME}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::plugin_ls() {
  local format="${1:-default}" list
  if ! list="$(_keepassxc-cli_with_args ls --flatten --recursive "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}" | { grep -v -e '/$' -e 'Recycle Bin/' || true; } | sort -f)"
  then
    pw::exit "Error while reading the database ${PW_KEYCHAIN}: Invalid credentials were provided, please try again."
  fi

  if [[ "${list}" != "[empty]" ]]; then
    case "${format}" in
      fzf) echo "${list}" | awk '{print $0 "\t\t\t" $0}' ;;
      *) echo "${list}" ;;
    esac
  fi
}

pw::plugin_fzf_preview() {
  declare -p PW_KEYCHAIN_ARGS
  declare -f _keepassxc-cli_with_args
  echo "_keepassxc-cli_with_args show \"${PW_KEYCHAIN}\" {4} <<< \"${PW_KEEPASSXC_PASSWORD}\""
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
