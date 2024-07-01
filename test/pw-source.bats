setup() {
  load 'pw'
  _setup
}

assert_bash_version_fail() {
  bats_require_minimum_version 1.5.0
  BASH_VERSION="$1" run --separate-stderr pw::require_bash_version
  assert_failure
  [[ -z "${output}" ]]
  [[ -n "${stderr}" ]]
}

assert_bash_version_success() {
  BASH_VERSION="$1" run pw::require_bash_version
  assert_success
  refute_output
}

@test "requires bash-4.2 or later" {
  _source_pw
  assert_bash_version_fail 3.2.0
  assert_bash_version_fail 4.1.0

  assert_bash_version_success 4.2.0
  assert_bash_version_success 4.4.0
  assert_bash_version_success 5.0.0
}

@test "resolves pw home" {
  _source_pw
  assert_equal "${PW_HOME}" "${PROJECT_ROOT}"
}

assert_pw_home() {
  assert_equal "${PW_HOME}" "${PROJECT_ROOT}"
}

@test "resolves pw home and follows symlink" {
  ln -s "${PROJECT_ROOT}/src/pw" "${BATS_TEST_TMPDIR}/pw"
  _source_pw "${BATS_TEST_TMPDIR}/pw"
  assert_pw_home
}

@test "resolves pw home and follows multiple symlinks" {
  mkdir "${BATS_TEST_TMPDIR}"/{src,bin}
  ln -s "${PROJECT_ROOT}/src/pw" "${BATS_TEST_TMPDIR}/src/pw"
  ln -s "${BATS_TEST_TMPDIR}/src/pw" "${BATS_TEST_TMPDIR}/bin/pw"
  _source_pw "${BATS_TEST_TMPDIR}/bin/pw"
  assert_pw_home
}
