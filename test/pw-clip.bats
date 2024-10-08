# shellcheck disable=SC2030,SC2031
export BATS_NO_PARALLELIZE_WITHIN_FILE=true
setup() {
  load 'pw'
  _setup
  export PW_PLUGINS="${BATS_TEST_DIRNAME}/fixtures/plugins"
  export PW_CLIP_TIME=1
}

_create_fake_keychain() {
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_test.keychain";
  touch "${PW_KEYCHAIN}"
}

_set_plugin_1() { export PW_TEST_PLUGIN_1=1; }

_wait() { sleep 2; }

@test "copies item password" {
  _create_fake_keychain
  _set_plugin_1
  pw name account url
  run pbpaste
  assert_success
  assert_output "plugin 1 get name account url ${PW_KEYCHAIN}"
}

@test "copies item details" {
  _create_fake_keychain
  _set_plugin_1
  pw show name account url
  run pbpaste
  assert_success
  assert_output "plugin 1 show name account url ${PW_KEYCHAIN}"
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

@test "clears clipboard after copying item" {
  _create_fake_keychain
  _set_plugin_1
  pw name
  _wait
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard after copying item when changed" {
  _create_fake_keychain
  _set_plugin_1
  pw name
  echo -n "after" | pbcopy
  _wait
  run pbpaste
  assert_output "after"
}
