# shellcheck disable=SC2030,SC2031
export BATS_NO_PARALLELIZE_WITHIN_FILE=true
setup() {
  load 'pw'
  _setup
  export PW_PLUGINS="${BATS_TEST_DIRNAME}/fixtures/plugins"
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/test keychain.test"
  export PW_CLIP_TIME=1
}

_wait() { sleep 2; }

@test "copies item password" {
  pw "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
  run pbpaste
  assert_success
  assert_output "test get <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "clears clipboard after copying item password" {
  pw "${NAME_A}"
  _wait
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard after copying item password when changed" {
  pw "${NAME_A}"
  echo -n "after" | pbcopy
  _wait
  run pbpaste
  assert_output "after"
}

@test "copies item details" {
  pw show "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
  run pbpaste
  assert_success
  assert_output "test show <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "clears clipboard after copying item details" {
  pw show "${NAME_A}"
  _wait
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard after copying item details when changed" {
  pw show "${NAME_A}"
  echo -n "after" | pbcopy
  _wait
  run pbpaste
  assert_output "after"
}

@test "generates and copies password" {
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw gen
  assert_success
  refute_output
  run pbpaste
  assert_output "11111"
}

@test "clears clipboard after generating password" {
  run pw gen
  _wait
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard after generating password when changed" {
  run pw gen
  echo -n "after" | pbcopy
  _wait
  run pbpaste
  assert_output "after"
}
