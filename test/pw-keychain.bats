# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
  _set_config_with_test_plugins
  TEST_KEYCHAIN="test keychain.test"
  KEYCHAIN_OPTIONS="key1=value1,key2=value2"
}

@test "picks single keychain" {
  _config_append_keychains "${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <${TEST_KEYCHAIN}> <default>"
}

@test "picks single keychain and separates options" {
  _config_append_keychains "${TEST_KEYCHAIN}:${KEYCHAIN_OPTIONS}"
  run pw ls
  assert_success
  assert_output "test ls <${KEYCHAIN_OPTIONS}> <> <${TEST_KEYCHAIN}> <default>"
}

@test "removes duplicates" {
  _config_append_keychains "${TEST_KEYCHAIN}" "${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <${TEST_KEYCHAIN}> <default>"
}

@test "ignores empty lines" {
  _config_append_keychains "" "${TEST_KEYCHAIN}" ""
  run pw ls
  assert_success
  assert_output "test ls <> <> <${TEST_KEYCHAIN}> <default>"
}

@test "prioritizes PW_KEYCHAIN over PW_KEYCHAINS" {
  _config_append_keychains "${TEST_KEYCHAIN}"
  export PW_KEYCHAIN="other test keychain.test"
  run pw ls
  assert_success
  assert_output "test ls <> <> <other test keychain.test> <default>"
}

@test "prioritizes PW_KEYCHAIN over PW_KEYCHAINS and separates options" {
  _config_append_keychains "${TEST_KEYCHAIN}"
  export PW_KEYCHAIN="other test keychain.test:${KEYCHAIN_OPTIONS}"
  run pw ls
  assert_success
  assert_output "test ls <${KEYCHAIN_OPTIONS}> <> <other test keychain.test> <default>"
}

@test "prioritizes pw -k over PW_KEYCHAINS" {
  _config_append_keychains "${TEST_KEYCHAIN}"
  run pw -k "other test keychain.test" ls
  assert_success
  assert_output "test ls <> <> <other test keychain.test> <default>"
}

@test "prioritizes pw -k over PW_KEYCHAINS and separates options" {
  _config_append_keychains "${TEST_KEYCHAIN}"
  run pw -k "other test keychain.test:${KEYCHAIN_OPTIONS}" ls
  assert_success
  assert_output "test ls <${KEYCHAIN_OPTIONS}> <> <other test keychain.test> <default>"
}

@test "replace ~ with real HOME" {
  # shellcheck disable=SC2088
  _config_append_keychains "~/${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <${HOME}/${TEST_KEYCHAIN}> <default>"
}

@test "replace \$HOME with real HOME" {
  _config_append_keychains "\$HOME/${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <${HOME}/${TEST_KEYCHAIN}> <default>"
}

@test "replace \${HOME} with real HOME" {
  _config_append_keychains "\${HOME}/${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <${HOME}/${TEST_KEYCHAIN}> <default>"
}

@test "irgnores comments with #" {
  _config_append_keychains "# comment"
  _config_append_keychains "${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <test keychain.test> <default>"
}

@test "irgnores comments with ;" {
  _config_append_keychains "; comment"
  _config_append_keychains "${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <test keychain.test> <default>"
}

@test "irgnores comments with indentation" {
  _config_append_keychains "    # comment"
  _config_append_keychains "${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <test keychain.test> <default>"
}

@test "trims indentation" {
  _config_append_keychains "    ${TEST_KEYCHAIN}"
  run pw ls
  assert_success
  assert_output "test ls <> <> <test keychain.test> <default>"
}

# bats test_tags=tag:manual_test
@test "selects keychain with fzf" {
  _skip_manual_test "'b keychain.test' using fzf (Press enter to continue ...)"
  read -rsp "Press enter to continue ..."

  _config_append_keychains "a keychain.test" "b keychain.test"
  run pw ls
  assert_success
  assert_output "test ls <> <> <b keychain.test> <default>"
}

@test "fails when PW_KEYCHAIN is empty" {
  export PW_KEYCHAIN=""
  run pw ls
  assert_failure
  cat << EOF | assert_output -
pw: no keychain was set!
Set a keychain with the -k option or provide a list of default keychains in ${XDG_CONFIG_HOME:-"${HOME}/.config"}/pw/config.
EOF
}

@test "fails when no keychains are discovered" {
  run pw ls
  assert_failure
  cat << EOF | assert_output -
pw: no keychain was set!
Set a keychain with the -k option or provide a list of default keychains in ${XDG_CONFIG_HOME:-"${HOME}/.config"}/pw/config.
EOF
}

@test "discovers keychains without duplicates" {
  export PW_TEST_PLUGIN_DISCOVER_DUPLICATE=1
  run pw ls
  assert_success
  assert_output "test ls <> <> <duplicate discovered keychain.test> <default>"
}

@test "fails when keychain does not exist" {
  export PW_KEYCHAIN="does not exist.keychain"
  run pw ls
  assert_failure
  assert_output "pw: ${PW_KEYCHAIN}: No such file or directory"
}

@test "prints supported file types" {
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/test keychain.fake"
  touch "${PW_KEYCHAIN}"
  run pw ls
  assert_failure
  cat << EOF | assert_output -
Could not detect plugin for ${PW_KEYCHAIN}
Supported file types are:
Test Collision
Test
EOF
}

@test "prints supported extensions" {
  run pw init "test keychain.fake"
  assert_failure
  cat << EOF | assert_output -
Could not detect plugin for test keychain.fake
Supported extensions are:
collision     - Test Collision
test          - Test
EOF
}

@test "fails when multiple plugins match with file type" {
  export PW_TEST_PLUGIN_COLLISION=1
  _config_append_keychains "${TEST_KEYCHAIN}"
  run pw ls
  assert_failure
  cat << EOF | assert_output -
pw: Multiple plugins found for ${TEST_KEYCHAIN}
${BATS_TEST_DIRNAME}/fixtures/plugins/collision
${BATS_TEST_DIRNAME}/fixtures/plugins/test
EOF
}

@test "fails when multiple plugins match with file extension" {
  export PW_TEST_PLUGIN_COLLISION=1
  run pw init "${TEST_KEYCHAIN}"
  assert_failure
  cat << EOF | assert_output -
pw: Multiple plugins found for ${TEST_KEYCHAIN}
${BATS_TEST_DIRNAME}/fixtures/plugins/collision
${BATS_TEST_DIRNAME}/fixtures/plugins/test
EOF
}
