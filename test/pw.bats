setup() {
  load 'pw'
  _setup
}

@test "loads pwrc when specified" {
  _set_pwrc_with_keychains "test-keychain"
  echo 'echo "# test pwrc sourced"' >> "${PW_RC}"
  run pw --help
  assert_output --partial "# test pwrc sourced"
}

@test "creates pwrc" {
  export PW_RC="${BATS_TEST_TMPDIR}/mypwrc.bash"
  run pw --help
  assert_file_exists "${PW_RC}"
}

@test "generates and copies password" {
  _skip_when_github_action "Doesn't work with GitHub actions for some reason"
  # shellcheck disable=SC2030,SC2031
  export PW_GEN_LENGTH=5
  run pw gen
  assert_success
  refute_output
  run pbpaste
  (("${#output}" == "${PW_GEN_LENGTH}"))
}

@test "generates and prints password" {
  _skip_when_github_action "Doesn't work with GitHub actions for some reason"
  # shellcheck disable=SC2030,SC2031
  export PW_GEN_LENGTH=5
  run pw -p gen
  assert_success
  assert_output
  (("${#output}" == "${PW_GEN_LENGTH}"))
}

@test "ignores sample plugin" {
  _source_pw
  run pw::plugins
  assert_output --partial "macos_keychain/hook.bash"
  assert_output --partial "keepassxc/hook.bash"

  refute_output --partial "sample/hook.bash"
}
