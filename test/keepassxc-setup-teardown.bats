setup() {
  load 'keepassxc'
  _setup
  # shellcheck disable=SC2016
  _config_append_with_plugin '$PW_HOME/plugins/keepassxc'
}

@test "creates keychain" {
  assert_file_not_exists "${PW_KEYCHAIN}"
  run pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  assert_file_exists "${PW_KEYCHAIN}"
}

@test "deletes keychain" {
  pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  run _delete_keychain
  assert_success
  assert_file_not_exists "${PW_KEYCHAIN}"
}
