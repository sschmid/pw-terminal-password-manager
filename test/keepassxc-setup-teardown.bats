setup() {
  load 'keepassxc'
  _setup
}

@test "creates keychain" {
  assert_file_not_exists "${PW_KEYCHAIN}"
  run pw init "${PW_KEYCHAIN}" <<< " test password "
  assert_success
  assert_file_exists "${PW_KEYCHAIN}"
}

@test "deletes keychain" {
  pw init "${PW_KEYCHAIN}" <<< " test password "
  run _delete_keychain
  assert_success
  assert_file_not_exists "${PW_KEYCHAIN}"
}
