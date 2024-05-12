setup() {
  load 'macos_keychain_security-test-helper.bash'
}

@test "sets up and tears down test keychain" {
  run ls ~/Library/Keychains
  assert_success
  refute_output --partial "${TEST_KEYCHAIN}"

  run _setup
  assert_success
  run ls ~/Library/Keychains
  assert_output --partial "${TEST_KEYCHAIN}"

  run _teardown
  assert_success
  run ls ~/Library/Keychains
  refute_output --partial "${TEST_KEYCHAIN}"
}
