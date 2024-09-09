# This is a sample plugin that you can copy and paste as a template for your own plugins.
# This sample plugin is ignored by pw and will not be loaded.

pw::prepare_keychain() {
  : # Prepare the keychain if necessary, e.g. by unlocking it
}

pw::plugin_init() {
  echo "[Sample Plugin] Creating new keychain '${PW_KEYCHAIN}'"
}

pw::plugin_add() {
  echo "[Sample Plugin] Adding item '$1' with account '$2' to keychain '${PW_KEYCHAIN}'"
}

pw::plugin_edit() {
  echo "[Sample Plugin] Editing item '$1' with account '$2' in keychain '${PW_KEYCHAIN}'"
}

pw::plugin_get() {
  echo "sample-password"
}

pw::plugin_rm() {
  echo "[Sample Plugin] Removing item '$1' from keychain '${PW_KEYCHAIN}'"
}

pw::plugin_ls() {
  local format="${1:-default}"
  local -a sample_items=(
    "sample_item1"
    "sample_item2"
    "sample_item3"
  )
  local -a sample_accounts=(
    "sample_account1"
    "sample_account2"
    "sample_account3"
  )
  local name account
  case "${format}" in
    fzf)
      for i in "${!sample_items[@]}"; do
        name="${sample_items[$i]}"
        account="${sample_accounts[$i]}"
        printf "%-40s\t%s\t%s\t%s\n" "${name}" "${account}" "${name}" "${account}"
      done
      ;;
    *)
      for i in "${!sample_items[@]}"; do
        name="${sample_items[$i]}"
        account="${sample_accounts[$i]}"
        printf "%-40s\t%s\n" "${name}" "${account}"
      done
      ;;
  esac
}

pw::plugin_fzf_preview() {
  # 3: item name
  # 4: account name
  echo "echo {3} {4}"
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
