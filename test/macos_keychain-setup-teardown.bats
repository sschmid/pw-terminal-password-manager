setup() {
  load 'macos_keychain'
  _setup
}

@test "creates keychain" {
  assert_file_not_exists "${PW_KEYCHAIN}"
  run pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  assert_file_exists "${PW_KEYCHAIN}"
}

@test "doesn't create keychain in ~/Library/Keychains" {
  pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  run ls ~/Library/Keychains
  refute_output --partial "$(basename "${PW_KEYCHAIN}")"
}

@test "deletes keychain" {
  pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  run _delete_keychain
  assert_success
  assert_file_not_exists "${PW_KEYCHAIN}"
}
