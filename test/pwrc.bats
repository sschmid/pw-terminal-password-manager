setup() {
  load 'pw-test-helper.bash'
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
