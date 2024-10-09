# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
  export PW_PLUGINS="${BATS_TEST_DIRNAME}/fixtures/plugins"
}

_create_fake_keychain() {
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_test.keychain";
  touch "${PW_KEYCHAIN}"
}

_set_plugin_1()    { export PW_TEST_PLUGIN_1=1; }
_set_plugin_2()    { export PW_TEST_PLUGIN_2=1; }
_set_plugin_fail() { export PW_TEST_PLUGIN_FAIL=1; }

@test "sets PW_KEYCHAIN with single item in PW_KEYCHAINS" {
  _set_pwrc_with_keychains "pw_test.keychain"
  _set_plugin_1
  run pw ls
  assert_success
  cat << EOF | assert_output -
plugin 1 ls pw_test.keychain
declare -A PW_KEYCHAIN_ARGS=()
EOF
}

@test "sets PW_KEYCHAIN with single item in PW_KEYCHAINS and separates args" {
  _set_pwrc_with_keychains "pw_test.keychain:key1=value1,key2=value2"
  _set_plugin_1
  run pw ls
  assert_success
  cat << EOF | assert_output -
plugin 1 ls pw_test.keychain
declare -A PW_KEYCHAIN_ARGS=([key2]="value2" [key1]="value1" )
EOF
}

@test "PW_KEYCHAIN overwrites PW_KEYCHAINS" {
  _set_pwrc_with_keychains "pw_test1.keychain"
  export PW_KEYCHAIN="pw_test2.keychain"
  _set_plugin_1
  run pw ls
  assert_success
  cat << EOF | assert_output -
plugin 1 ls pw_test2.keychain
declare -A PW_KEYCHAIN_ARGS=()
EOF
}

@test "PW_KEYCHAIN overwrites PW_KEYCHAINS and separates args" {
  _set_pwrc_with_keychains "pw_test1.keychain"
  export PW_KEYCHAIN="pw_test2.keychain:key1=value1,key2=value2"
  _set_plugin_1
  run pw ls
  assert_success
  cat << EOF | assert_output -
plugin 1 ls pw_test2.keychain
declare -A PW_KEYCHAIN_ARGS=([key2]="value2" [key1]="value1" )
EOF
}

@test "pw -k overwrites PW_KEYCHAINS" {
  _set_pwrc_with_keychains "pw_test1.keychain"
  _set_plugin_1
  run pw -k pw_test2.keychain ls
  assert_success
  cat << EOF | assert_output -
plugin 1 ls pw_test2.keychain
declare -A PW_KEYCHAIN_ARGS=()
EOF
}

@test "pw -k overwrites PW_KEYCHAINS and separates args" {
  _set_pwrc_with_keychains "pw_test1.keychain"
  _set_plugin_1
  run pw -k pw_test2.keychain:key1=value1,key2=value2 ls
  assert_success
  cat << EOF | assert_output -
plugin 1 ls pw_test2.keychain
declare -A PW_KEYCHAIN_ARGS=([key2]="value2" [key1]="value1" )
EOF
}

# bats test_tags=tag:manual_test
@test "selects keychain with fzf" {
  _skip_manual_test "please select 'pw_test2.keychain'"
  read -rsp "Press enter to continue ..."

  _set_pwrc_with_keychains "pw_test1.keychain" "pw_test2.keychain"
  _set_plugin_1
  run pw ls

  assert_success
  cat << EOF | assert_output -
plugin 1 ls pw_test2.keychain
declare -A PW_KEYCHAIN_ARGS=()
EOF
}

@test "fails when PW_KEYCHAIN is empty" {
  _set_pwrc_with_keychains ""
  run pw -p name
  assert_failure
  cat << EOF | assert_output -
pw: no keychain was set!
Set a keychain with the -k option or provide a list of default keychains in your .pwrc file (${PW_RC}).
EOF
}

@test "discovers keychains without duplicates" {
  _set_pwrc_with_keychains ""
  _set_plugin_2
  run pw -p name account url
  assert_success
  assert_output "plugin 2 get name account url test 2 keychain"
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
Test File Type Fail
Test File Type Modify
EOF
}

@test "prints supported extensions" {
  run pw init "test.keychain"
  assert_failure
  cat << EOF | assert_output -
Could not detect plugin for test.keychain
Supported extensions are:
ext1          - Test File Type 1
ext2          - Test File Type 2
extf          - Test File Type Fail
extm          - Test File Type Modify
EOF
}

@test "fails when multiple plugins match with file type" {
  _create_fake_keychain
  _set_plugin_1
  _set_plugin_2
  run pw ls
  assert_failure
  cat << EOF | assert_output -
pw: Multiple plugins found for ${PW_KEYCHAIN}
${BATS_TEST_DIRNAME}/fixtures/plugins/test1
${BATS_TEST_DIRNAME}/fixtures/plugins/test2
EOF
}

@test "fails when multiple plugins match with file extension" {
  _set_plugin_1
  _set_plugin_2
  run pw init "test.keychain"
  assert_failure
  cat << EOF | assert_output -
pw: Multiple plugins found for test.keychain
${BATS_TEST_DIRNAME}/fixtures/plugins/test1
${BATS_TEST_DIRNAME}/fixtures/plugins/test2
EOF
}

@test "inits keychain" {
  _set_plugin_1
  run pw init "test.keychain"
  assert_success
  cat << EOF | assert_output -
plugin 1 init test.keychain
declare -A PW_KEYCHAIN_ARGS=()
EOF
}

@test "inits keychain and separates args" {
  _set_plugin_1
  run pw init "test.keychain:key1=value1,key2=value2"
  assert_success
  cat << EOF | assert_output -
plugin 1 init test.keychain
declare -A PW_KEYCHAIN_ARGS=([key2]="value2" [key1]="value1" )
EOF
}

@test "init fails when keychain already exists" {
  _create_fake_keychain
  _set_plugin_1
  assert_init_fails
}

@test "prints item password" {
  _create_fake_keychain
  _set_plugin_1
  run pw -p name account url
  assert_success
  assert_output "plugin 1 get name account url ${PW_KEYCHAIN}"
}

@test "prints item password with -pk" {
  _create_fake_keychain
  _set_plugin_1
  run pw -pk "${PW_KEYCHAIN}" name account url
  assert_success
  assert_output "plugin 1 get name account url ${PW_KEYCHAIN}"
}

@test "prints item details" {
  _create_fake_keychain
  _set_plugin_1
  run pw -p show name account url
  assert_success
  assert_output "plugin 1 show name account url ${PW_KEYCHAIN}"
}

@test "fails when item selection fails" {
  _create_fake_keychain
  _set_plugin_fail
  run pw
  assert_failure
  refute_output
}

@test "adds item" {
  _create_fake_keychain
  _set_plugin_1
  run pw add name account url <<< password
  assert_success
  assert_output "plugin 1 add name account url password ${PW_KEYCHAIN}"
}

# bats test_tags=tag:manual_test
@test "adds item interactively" {
  _skip_manual_test "name account url notes (2x ctrl+D) pass pass"
  _create_fake_keychain
  _set_plugin_1
  run pw add
  assert_success
  cat << EOF | assert_output -
Title: Username: URL: Notes: Enter multi-line input (end with Ctrl+D):
Enter password for 'name' (leave empty to generate password):
Retype password for 'name':
plugin 1 add name account url pass ${PW_KEYCHAIN}
EOF
}

@test "removes item" {
  _create_fake_keychain
  _set_plugin_1
  run pw rm name account url
  assert_success
  assert_output "plugin 1 rm name account url ${PW_KEYCHAIN}"
}

# bats test_tags=tag:manual_test
@test "removes item interactively" {
  _skip_manual_test "select 'name 2', then enter 'y'"
  read -rsp "Press enter to continue ..."
  _create_fake_keychain
  _set_plugin_2
  run pw rm
  assert_success
  cat << EOF | assert_output -
Do you really want to remove 'name 2' 'account 2' from '${PW_KEYCHAIN}'? (y / N): plugin 2 rm name 2 account 2 url 2 ${PW_KEYCHAIN}
EOF
}

@test "edits item" {
  _create_fake_keychain
  _set_plugin_1
  run pw edit name account url <<< password2
  assert_success
  assert_output "plugin 1 edit name account url password2 ${PW_KEYCHAIN}"
}

@test "lists items" {
  _create_fake_keychain
  _set_plugin_1
  run pw ls
  assert_success
  cat << EOF | assert_output -
plugin 1 ls ${PW_KEYCHAIN}
declare -A PW_KEYCHAIN_ARGS=()
EOF
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
