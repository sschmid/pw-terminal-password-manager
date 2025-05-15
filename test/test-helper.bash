# shellcheck disable=SC2034
_common_setup() {
  load 'test_helper/bats-support/load.bash'
  load 'test_helper/bats-assert/load.bash'
  load 'test_helper/bats-file/load.bash'

  export XDG_CONFIG_HOME="${BATS_TEST_TMPDIR}/.config"
  export PW_CONFIG="${XDG_CONFIG_HOME}/pw/config"
  mkdir -p "${XDG_CONFIG_HOME}/pw"

  PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." &>/dev/null && pwd)"
  PATH="${PROJECT_ROOT}/src:${PATH}"

  KEYCHAIN_TEST_PASSWORD=" test password "
  NAME_A=" a test name "
  NAME_B=" b test name "
  ACCOUNT_A=" a test account "
  ACCOUNT_B=" b test account "
  URL_A=" a test url "
  URL_B=" b test url "
  SINGLE_LINE_NOTES=" a single line note "
  MULTI_LINE_NOTES=" a test note
with multiple lines
and spaces "
  PW_1=" 1 test pw "
  PW_2=" 2 test pw "
  PW_3=" 3 test pw "
}

_set_config_with_plugin() {
  cat > "${PW_CONFIG}" << EOF
[plugins]
$1
EOF
}

_set_config_with_test_plugins() {
  cat > "${PW_CONFIG}" << EOF
[plugins]
${BATS_TEST_DIRNAME}/fixtures/plugins/collision
${BATS_TEST_DIRNAME}/fixtures/plugins/test
EOF
}

_config_append_keychains() {
  echo "[keychains]" >> "${PW_CONFIG}"
  printf "%s\n" "$@" >> "${PW_CONFIG}"
}

assert_init_already_exists() {
  run pw init "${PW_KEYCHAIN}"
  assert_failure
  assert_output "pw: ${PW_KEYCHAIN} already exists."
}

assert_item_exists() {
  local password="$1"; shift
  run pw -p "$@"
  assert_success
  assert_output "${password}"
}

assert_item_not_exists() {
  run pw "$@"
  assert_failure
  assert_item_not_exists_output "$@"
}

assert_adds_item() {
  local password="$1"; shift
  run pw add "$@" <<< "${password}"
  assert_success
  refute_output
}

assert_adds_item_with_keychain_password() {
  local password="$1"; shift
  run pw add "$@" << EOF
${KEYCHAIN_TEST_PASSWORD}
${password}
EOF
  assert_success
  refute_output
}

assert_item_already_exists() {
  local password="$1"; shift
  run pw add "$@" <<< "${password}"
  assert_failure
  assert_item_already_exists_output "$@"
}

assert_item_already_exists_with_keychain_password() {
  local password="$1"; shift
  run pw add "$@" << EOF
${KEYCHAIN_TEST_PASSWORD}
${password}
EOF
  assert_failure
  assert_item_already_exists_output "$@"
}

assert_removes_item() {
  run pw rm "$@"
  assert_success
  assert_removes_item_output "$@"
}

assert_rm_not_found() {
  run pw rm "$@"
  assert_failure
  assert_rm_not_found_output "$@"
}

assert_edits_item() {
  local password="$1"; shift
  run pw edit "$@" <<< "${password}"
  assert_success
  refute_output
}

assert_edits_item_with_keychain_password() {
  local password="$1"; shift
  run pw edit "$@" << EOF
${KEYCHAIN_TEST_PASSWORD}
${password}
EOF
  assert_success
  refute_output
}

_copy() {
  "${PROJECT_ROOT}/src/copy"
}

_paste() {
  "${PROJECT_ROOT}/src/paste"
}

_skip_when_not_macos() {
  [[ "${OSTYPE}" == "darwin"* ]] || skip "Not macOS"
}

_skip_manual_test() {
  if [[ -v PW_TEST_RUN_MANUAL_TESTS ]]; then
    echo "# Please enter $1" >&3
  else
    skip "Requires user input. Use PW_TEST_RUN_MANUAL_TESTS=1 test/run to also run manual tests."
  fi
}
