setup_file() {
  export BATS_NO_PARALLELIZE_WITHIN_FILE=true
  export GNUPGHOME="${BATS_FILE_TMPDIR}/.gnupg"
  gpg --batch --pinentry-mode loopback --passphrase pw_test_password \
      --import "${BATS_TEST_DIRNAME}/fixtures/pw_test_1.key"
  gpgconf --kill gpg-agent
}

setup() {
  load 'gpg'
  _setup
}

teardown() {
  gpgconf --kill gpg-agent
}

@test "creates keychain" {
  assert_dir_not_exists "${PW_KEYCHAIN}"
  run pw init "${PW_KEYCHAIN}"
  assert_success
  assert_dir_exists "${PW_KEYCHAIN}"

  run ls -ld "${PW_KEYCHAIN}"
  assert_success
  assert_output --partial "drwx------"
}

@test "deletes keychain" {
  pw init "${PW_KEYCHAIN}"
  run _delete_keychain
  assert_success
  assert_dir_not_exists "${PW_KEYCHAIN}"
}

@test "uses test key" {
  run gpg -K
  assert_success
  assert_output --partial "8F1F7B428DC46AD4AD2E5123691ED007F1E410B0"
}
