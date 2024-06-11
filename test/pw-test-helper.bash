load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'
load 'test_helper/bats-file/load.bash'

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." > /dev/null 2>&1 && pwd)"
PATH="${PROJECT_ROOT}/src:${PATH}"

_set_pwrc_with_keychains() {
  export PW_RC="${BATS_TEST_TMPDIR}/pwrc.bash"
  echo "PW_KEYCHAINS=($1)" > "${PW_RC}"
}

_skip_when_github_action() {
  [[ "${PROJECT_ROOT}" != "/Users/runner/work/"* ]] || skip "$@"
}
