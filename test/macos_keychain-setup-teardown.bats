setup() {
  load 'macos_keychain.bash'
}

@test "setup creates keychain" {
  assert_file_not_exists "${TEST_KEYCHAIN}"

  run _setup
  assert_success
  assert_file_exists "${TEST_KEYCHAIN}"
}

@test "setup doesn't create keychain in ~/Library/Keychains" {
  _setup
  run ls ~/Library/Keychains
  refute_output --partial "$(basename "${TEST_KEYCHAIN}")"
}

@test "teardown deletes keychain" {
  _setup
  run _teardown
  assert_success
  assert_file_not_exists "${TEST_KEYCHAIN}"
}
