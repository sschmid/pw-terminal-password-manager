setup_file() {
  export GNUPGHOME="${BATS_FILE_TMPDIR}/.gnupg"
  gpg --batch --pinentry-mode loopback --passphrase pw_test_password \
      --import "${BATS_TEST_DIRNAME}/fixtures/gpg.key"
}

teardown_file() {
  killall gpg-agent 2> /dev/null || true
}

setup() {
  load 'gpg'
  _setup
}

@test "creates keychain" {
  assert_dir_not_exists "${PW_KEYCHAIN}"
  run pw::plugin_init
  assert_success
  assert_dir_exists "${PW_KEYCHAIN}"

  run ls -ld "${PW_KEYCHAIN}"
  assert_success
  assert_output --partial "drwx------"
}

@test "deletes keychain" {
  pw::plugin_init
  run _delete_keychain
  assert_success
  assert_dir_not_exists "${PW_KEYCHAIN}"
}

@test "uses test key" {
  run gpg -K
  assert_success
  assert_output --partial "D520721A5712B7B8B3517F399F2E5ED80579EFDB"
}
