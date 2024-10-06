# This is a sample plugin that you can copy and paste as a template for your own plugins.
# This sample plugin is ignored by pw and will not be loaded.

pw::prepare_keychain() {
  : # Prepare the keychain if necessary, e.g. by unlocking it
}

pw::plugin_init() {
  echo "[Sample Plugin] Creating new keychain '${PW_KEYCHAIN}'"
}

pw::plugin_add() {
  cat << EOF
[Sample Plugin] ${PW_KEYCHAIN} add
Name: ${PW_NAME}
Account: ${PW_ACCOUNT}
URL: ${PW_URL}
Notes: ${PW_NOTES}
Password: ${PW_PASSWORD}
EOF
}

pw::plugin_edit() {
  cat << EOF
[Sample Plugin] ${PW_KEYCHAIN} edit
Name: ${PW_NAME}
Account: ${PW_ACCOUNT}
URL: ${PW_URL}
Password: ${PW_PASSWORD}
EOF
}

pw::plugin_get() {
  cat << EOF
[Sample Plugin] ${PW_KEYCHAIN} get
Name: ${PW_NAME}
Account: ${PW_ACCOUNT}
URL: ${PW_URL}
EOF
}

pw::plugin_show() {
  cat << EOF
[Sample Plugin] ${PW_KEYCHAIN} show
Name: ${PW_NAME}
Account: ${PW_ACCOUNT}
URL: ${PW_URL}
EOF
}

pw::plugin_rm() {
  cat << EOF
[Sample Plugin] ${PW_KEYCHAIN} rm
Name: ${PW_NAME}
Account: ${PW_ACCOUNT}
URL: ${PW_URL}
EOF
}

pw::plugin_ls() {
  local format="${1:-default}"
  local -a items=("sample_item1" "sample_item2" "sample_item3")
  local -a accounts=("sample_account1" "sample_account2" "sample_account3")
  local -a urls=("sample_url1" "sample_url2" "sample_url3")

  case "${format}" in
    fzf) printf_format="%-24s\t%-24s\t%s\t%s\t%s\t%s\n" ;;
    *) printf_format="%-24s\t%-24s\t%s\n" ;;
  esac

  local name account url
  for i in "${!items[@]}"; do
    name="${items[$i]}"
    account="${accounts[$i]}"
    url="${urls[$i]}"
    # shellcheck disable=SC2059
    printf "${printf_format}" "${name}" "${account}" "${url}" "${name}" "${account}" "${url}"
  done
}

pw::plugin_fzf_preview() {
  # shellcheck disable=SC2028
  echo 'printf "Name: %s\nAccount: %s\nURL: %s\n" {4} {5} {6}'
}

pw::plugin_open() {
  echo "[Sample Plugin] Opening keychain '${PW_KEYCHAIN}'"
}

pw::plugin_lock() {
  echo "[Sample Plugin] Locking keychain '${PW_KEYCHAIN}'"
}

pw::plugin_unlock() {
  echo "[Sample Plugin] Unlocking keychain '${PW_KEYCHAIN}'"
}
