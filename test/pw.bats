# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
}

@test "loads pwrc when specified" {
  _set_pwrc_with_keychains "test-keychain"
  echo 'echo "# test pwrc sourced"' >> "${PW_RC}"
  run pw -h
  assert_output --partial "# test pwrc sourced"
}

@test "creates pwrc" {
  export PW_RC="${BATS_TEST_TMPDIR}/mypwrc.bash"
  run pw -h
  assert_file_exists "${PW_RC}"
}

@test "exits when invalid option" {
  run pw -x -h
  assert_failure
  assert_output "Invalid option: -x"
}

@test "generates and copies password" {
  _skip_if_github_action "Doesn't work with GitHub actions for some reason"
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw gen
  assert_success
  refute_output
  run pbpaste
  assert_output "11111"
}

@test "clears clipboard after generating password" {
  export PW_CLIP_TIME=1
  run pw gen
  sleep 2
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard when changed" {
  export PW_CLIP_TIME=1
  run pw gen
  echo -n "after" | pbcopy
  sleep 2
  run pbpaste
  assert_output "after"
}

@test "generates and prints password" {
  _skip_if_github_action "Doesn't work with GitHub actions for some reason"
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw -p gen
  assert_success
  assert_output "11111"
}

@test "generates password with specified length" {
  _skip_if_github_action "Doesn't work with GitHub actions for some reason"
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw -p gen 8
  assert_success
  assert_output "11111111"
}

@test "generates password with specified character class" {
  _skip_if_github_action "Doesn't work with GitHub actions for some reason"
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw -p gen 8 "2"
  assert_success
  assert_output "22222222"
}
