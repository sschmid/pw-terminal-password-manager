setup() {
  load 'macos_keychain'
  _setup
}

@test "creates keychain" {
  assert_file_not_exists "${PW_KEYCHAIN}"
  run pw::plugin_init <<< " test password "
  assert_success
  assert_file_exists "${PW_KEYCHAIN}"
}

@test "doesn't create keychain in ~/Library/Keychains" {
  pw::plugin_init <<< " test password "
  run ls ~/Library/Keychains
  refute_output --partial "$(basename "${PW_KEYCHAIN}")"
}

@test "deletes keychain" {
  pw::plugin_init <<< " test password "
  run _delete_keychain
  assert_success
  assert_file_not_exists "${PW_KEYCHAIN}"
}
