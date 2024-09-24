# shellcheck disable=SC2034
_common_setup() {
  load 'test_helper/bats-support/load.bash'
  load 'test_helper/bats-assert/load.bash'
  load 'test_helper/bats-file/load.bash'

  PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." > /dev/null 2>&1 && pwd)"
  PATH="${PROJECT_ROOT}/src:${PATH}"

  KEYCHAIN_TEST_PASSWORD=" test password "

  NAME_A=" a test name "
  NAME_B=" b test name "
  ACCOUNT_A=" a test account "
  ACCOUNT_B=" b test account "
  URL_A=" a test url "
  URL_B=" b test url "
  NOTES_A=" a test note "
  PW_1=" 1 test pw "
  PW_2=" 2 test pw "
  PW_3=" 3 test pw "
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

assert_item_already_exists() {
  local password="$1"; shift
  run pw add "$@" <<< "${password}"
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

_skip_manual_test() {
  if [[ -v PW_TEST_RUN_MANUAL_TESTS ]]; then
    echo "# Please enter $1" >&3
  else
    skip "Requires user input. Use PW_TEST_RUN_MANUAL_TESTS=1 test/run to also run manual tests."
  fi
}

_skip_if_github_action() {
  [[ "${PROJECT_ROOT}" != "/Users/runner/work/"* ]] || skip "$@"
}
