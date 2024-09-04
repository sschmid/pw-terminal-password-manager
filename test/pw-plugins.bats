# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
  export PW_PLUGINS="${PROJECT_ROOT}/test/fixtures/plugins"
}

_create_fake_keychain() {
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_test.keychain";
  touch "${PW_KEYCHAIN}"
}

_set_plugin_1() { export PW_TEST_PLUGIN_1=1; }
_set_plugin_2() { export PW_TEST_PLUGIN_2=1; }

@test "sets PW_KEYCHAIN with single item in PW_KEYCHAINS" {
  _set_pwrc_with_keychains "pw_test.keychain"
  _set_plugin_1
  run pw ls
  assert_success
  assert_output "plugin 1 ls pw_test.keychain"
}

@test "PW_KEYCHAIN overwrites PW_KEYCHAINS" {
  _set_pwrc_with_keychains "pw_test1.keychain"
  export PW_KEYCHAIN="pw_test2.keychain"
  _set_plugin_1
  run pw ls
  assert_success
  assert_output "plugin 1 ls pw_test2.keychain"
}

@test "fails when keychain does not exist" {
  export PW_KEYCHAIN="doesNotExist.keychain"
  run pw ls
  assert_failure
  assert_output "pw: ${PW_KEYCHAIN}: No such file or directory"
}

@test "prints supported file types" {
  _create_fake_keychain
  run pw ls
  assert_failure
  cat << EOF | assert_output -
Could not detect plugin for ${PW_KEYCHAIN}
Supported file types are:
Test File Type 1
Test File Type 2
EOF
}

@test "prints supported extensions" {
  run pw init "test.keychain"
  assert_failure
  cat << EOF | assert_output -
Could not detect plugin for test.keychain
Supported extensions are:
test-keychain-1 (Test File Type 1)
test-keychain-2 (Test File Type 2)
EOF
}

@test "fails when multiple plugins match with file type" {
  _create_fake_keychain
  _set_plugin_1
  _set_plugin_2
  run pw ls
  assert_failure
  assert_output "pw: Multiple plugins found for ${PW_KEYCHAIN}"
}

@test "fails when multiple plugins match with file extension" {
  _set_plugin_1
  _set_plugin_2
  run pw init "test.keychain"
  assert_failure
  assert_output "pw: Multiple plugins found for test.keychain"
}

@test "inits keychain" {
  _set_plugin_1
  run pw init "test.keychain"
  assert_success
  assert_output "plugin 1 init test.keychain"
}

@test "init fails when keychain already exists" {
  _create_fake_keychain
  _set_plugin_1
  run pw init "${PW_KEYCHAIN}"
  assert_failure
  assert_output "pw: ${PW_KEYCHAIN}: File already exists"
}

@test "prints item password" {
  _create_fake_keychain
  _set_plugin_1
  run pw -p name account
  assert_success
  assert_output "plugin 1 get name account ${PW_KEYCHAIN}"
}

@test "copies item password" {
  _create_fake_keychain
  _set_plugin_1
  pw name account
  run pbpaste
  assert_success
  assert_output "plugin 1 get name account ${PW_KEYCHAIN}"
}

@test "clears clipboard after copying item" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  _create_fake_keychain
  _set_plugin_1
  pw name account
  sleep 2
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard when changed" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  _create_fake_keychain
  _set_plugin_1
  pw name account
  echo -n "after" | pbcopy
  sleep 2
  run pbpaste
  assert_output "after"
}

@test "adds item" {
  _create_fake_keychain
  _set_plugin_1
  run pw add name account <<< password
  assert_success
  assert_output "plugin 1 add name account password ${PW_KEYCHAIN}"
}

@test "removes item" {
  _create_fake_keychain
  _set_plugin_1
  run pw rm name account
  assert_success
  assert_output "plugin 1 rm name account ${PW_KEYCHAIN}"
}

@test "edits item" {
  _create_fake_keychain
  _set_plugin_1
  run pw edit name account <<< password2
  assert_success
  assert_output "plugin 1 edit name account password2 ${PW_KEYCHAIN}"
}

@test "lists items" {
  _create_fake_keychain
  _set_plugin_1
  run pw ls
  assert_success
  assert_output "plugin 1 ls ${PW_KEYCHAIN}"
}

@test "opens keychain" {
  _create_fake_keychain
  _set_plugin_1
  run pw open
  assert_success
  assert_output "plugin 1 open ${PW_KEYCHAIN}"
}

@test "locks keychain" {
  _create_fake_keychain
  _set_plugin_1
  run pw lock
  assert_success
  assert_output "plugin 1 lock ${PW_KEYCHAIN}"
}

@test "unlocks keychain" {
  _create_fake_keychain
  _set_plugin_1
  run pw unlock
  assert_success
  assert_output "plugin 1 unlock ${PW_KEYCHAIN}"
}
