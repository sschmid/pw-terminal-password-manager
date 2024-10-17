# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
}

_set_pwrc_with_keychains_old() {
  echo "PW_KEYCHAINS=($1)" > "${PW_RC}"
}

# bats test_tags=tag:manual_test
@test "migrates old pwrc" {
  _skip_manual_test "'y'"

  local keychain="${BATS_TEST_TMPDIR}/test keychain.test"
  _set_pwrc_with_keychains_old "'${keychain}'"
  touch "${keychain}"

  export PW_PLUGINS="${BATS_TEST_DIRNAME}/fixtures/plugins"
  run pw ls
  assert_success
  assert_output "pw 9.0.0 introduced a new .pwrc format. Would you like to automatically upgrade your .pwrc file? (y / N): test ls <> <> <${keychain}> <default>"

  run cat "${PW_RC}"
  assert_success
  assert_output "${keychain}"
}

@test "ignores new pwrc" {
  local keychain="${BATS_TEST_TMPDIR}/test keychain.test"
  _set_pwrc_with_keychains "${keychain}"
  touch "${keychain}"

  export PW_PLUGINS="${BATS_TEST_DIRNAME}/fixtures/plugins"
  run pw ls
  assert_success
  assert_output "test ls <> <> <${keychain}> <default>"

  run cat "${PW_RC}"
  assert_success
  assert_output "${keychain}"
}
