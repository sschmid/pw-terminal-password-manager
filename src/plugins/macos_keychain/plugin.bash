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
  security add-generic-password \
    -l "${PW_NAME:-"${PW_URL}"}" \
    -a "${PW_ACCOUNT}" \
    -s "${PW_URL:="${PW_NAME}"}" \
    ${PW_NOTES:+-j "${PW_NOTES}"} \
    -w "${PW_PASSWORD}" \
    "${PW_KEYCHAIN}"
}

pw::plugin_edit() {
  security add-generic-password -U \
    -l "${PW_NAME:-"${PW_URL}"}" \
    -a "${PW_ACCOUNT}" \
    -s "${PW_URL:="${PW_NAME}"}" \
    -w "${PW_PASSWORD}" \
    "${PW_KEYCHAIN}"
}

pw::plugin_get() {
  security find-generic-password \
    ${PW_NAME:+-l "${PW_NAME}"} \
    ${PW_ACCOUNT:+-a "${PW_ACCOUNT}"} \
    ${PW_URL:+-s "${PW_URL}"} \
    -w "${PW_KEYCHAIN}"
}

pw::plugin_rm() {
  security delete-generic-password \
    ${PW_NAME:+-l "${PW_NAME}"} \
    ${PW_ACCOUNT:+-a "${PW_ACCOUNT}"} \
    ${PW_URL:+-s "${PW_URL}"} \
    "${PW_KEYCHAIN}" > /dev/null
}

pw::plugin_ls() {
  local format="${1:-default}" printf_format
  case "${format}" in
    fzf) printf_format='printf "%-24s\t%-24s\t%s\t%s\t%s\t%s\n", label, account, service, label, account, service' ;;
    *) printf_format='printf "%-24s\t%-24s\t%s\n", label, account, service' ;;
  esac

  security dump-keychain "${PW_KEYCHAIN}" | _plugin_get_details "${printf_format}" | sort -f
}

pw::plugin_fzf_preview() {
  # unlocks the keychain if necessary and only previews if the keychain is unlocked
  if security show-keychain-info "${PW_KEYCHAIN}" &> /dev/null; then
    declare -f _plugin_get_details _plugin_fzf_preview
    echo "_plugin_fzf_preview \"${PW_KEYCHAIN}\""
  fi
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

_plugin_get_details() {
  # KCOV_EXCL_START
  # shellcheck disable=SC2016
  local awk_cmd='BEGIN { FS="<blob>=" }
/0x00000007 / { label = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2) }
/"acct"/ { account = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2) }
/"icmt"/ { comments = ($2 == "<NULL>") ? "" : $2 }
/"svce"/ { service = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2);'
  # KCOV_EXCL_STOP

  awk "${awk_cmd} $1 }"
}

# KCOV_EXCL_START
# shellcheck disable=SC1083
_plugin_fzf_preview() {
  local comment
  comment="$(security find-generic-password -l {4} -a {5} -s {6} -g "$1" 2> /dev/null | _plugin_get_details 'printf "%s\n", comments')"
  echo "Comment:"
  if [[ "${comment}" == "0x"* ]]
  then xxd -r -p <<< "${comment%%  *}"
  else echo "${comment:1:-1}"
  fi
}
# KCOV_EXCL_STOP
