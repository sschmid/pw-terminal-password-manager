_common_setup() {
  load 'test_helper/bats-support/load.bash'
  load 'test_helper/bats-assert/load.bash'
  load 'test_helper/bats-file/load.bash'

  PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." > /dev/null 2>&1 && pwd)"
  PATH="${PROJECT_ROOT}/src:${PATH}"
}

_skip_manual_test() {
  if [[ -v PW_TEST_RUN_MANUAL_TESTS ]]; then
    echo "# Please enter '$*'" >&3
    # shellcheck disable=SC2154
    echo "${output}" >&3
  else
    skip "requires user input"
  fi
}

_skip_when_github_action() {
  [[ "${PROJECT_ROOT}" != "/Users/runner/work/"* ]] || skip "$@"
}
