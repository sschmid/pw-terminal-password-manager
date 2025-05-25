export BATS_NO_PARALLELIZE_WITHIN_FILE=true

setup() {
  load 'pw'
  _setup
  _set_config_with_copy_paste
  _config_append_with_test_plugins
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/test keychain.test"
  export PW_CLIP_TIME=1
}

_wait() { sleep 2; }

@test "copies item password" {
  run pw "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
  assert_success
  run _paste
  assert_success
  assert_output "test get <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "clears clipboard after copying item password" {
  run pw "${NAME_A}"
  assert_success
  _wait
  run _paste
  refute_output
}

@test "doesn't clear clipboard after copying item password when changed" {
  run pw "${NAME_A}"
  assert_success
  echo -n "after" | _copy
  _wait
  run _paste
  assert_output "after"
}

@test "copies item details" {
  run pw show "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
  assert_success
  run _paste
  assert_success
  assert_output "test show <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "clears clipboard after copying item details" {
  run pw show "${NAME_A}"
  assert_success
  _wait
  run _paste
  refute_output
}

@test "doesn't clear clipboard after copying item details when changed" {
  run pw show "${NAME_A}"
  assert_success
  echo -n "after" | _copy
  _wait
  run _paste
  assert_output "after"
}

@test "generates and copies password" {
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw gen
  assert_success
  refute_output
  run _paste
  assert_output "11111"
}

@test "clears clipboard after generating password" {
  run pw gen
  _wait
  run _paste
  refute_output
}

@test "doesn't clear clipboard after generating password when changed" {
  run pw gen
  echo -n "after" | _copy
  _wait
  run _paste
  assert_output "after"
}

@test "env vars override config" {
  export PW_COPY="cat > ${BATS_TEST_TMPDIR}/my_clipboard"
  export PW_PASTE="cat ${BATS_TEST_TMPDIR}/my_clipboard"
  run pw "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
  assert_success

  run cat "${BATS_TEST_TMPDIR}/my_clipboard"
  assert_success
  assert_output "test get <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}
