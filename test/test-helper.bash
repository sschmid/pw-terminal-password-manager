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
  PW_1=" 1 test pw "
  PW_2=" 2 test pw "
  PW_3=" 3 test pw "
}

_skip_manual_test() {
  if [[ -v PW_TEST_RUN_MANUAL_TESTS ]]; then
    echo "# Please enter '$1'${2:+ "$2"}" >&3
  else
    skip "Requires user input. Use PW_TEST_RUN_MANUAL_TESTS=1 test/run to also run manual tests."
  fi
}

_skip_if_github_action() {
  [[ "${PROJECT_ROOT}" != "/Users/runner/work/"* ]] || skip "$@"
}
