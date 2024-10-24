# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
}

assert_pw_home() {
  assert_output --partial "🔐 pw $(cat "${PROJECT_ROOT}/version.txt") - Terminal Password Manager"
}

@test "prints help" {
  run pw -h
  assert_success
  assert_output --partial "usage: pw"
}

@test "resolves pw home" {
  run pw -h
  assert_success
  assert_pw_home
}

@test "resolves pw home and follows symlink" {
  ln -s "${PROJECT_ROOT}/src/pw" "${BATS_TEST_TMPDIR}/pw"
  run "${BATS_TEST_TMPDIR}/pw" -h
  assert_success
  assert_pw_home
}

@test "resolves pw home and follows multiple symlinks" {
  mkdir "${BATS_TEST_TMPDIR}"/{src,bin}
  ln -s "${PROJECT_ROOT}/src/pw" "${BATS_TEST_TMPDIR}/src/pw"
  ln -s "${BATS_TEST_TMPDIR}/src/pw" "${BATS_TEST_TMPDIR}/bin/pw"
  run "${BATS_TEST_TMPDIR}/bin/pw" -h
  assert_success
  assert_pw_home
}

@test "doesn't source pwrc" {
  _set_pwrc_with_keychains " test keychain "
  echo 'echo "# test pwrc sourced"' >> "${PW_RC}"
  run pw -h
  refute_output --partial "# test pwrc sourced"
}

@test "doesn't create pwrc" {
  PW_RC="${BATS_TEST_TMPDIR}/mypwrc"
  run pw -h
  assert_file_not_exists "${PW_RC}"
}

@test "exits when invalid option" {
  run pw -x -h
  assert_failure
  assert_output "Invalid option: -x"
}

@test "generates and prints password" {
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw -p gen
  assert_success
  assert_output "11111"
}

@test "generates password with specified length" {
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw -p gen 8
  assert_success
  assert_output "11111111"
}

@test "generates password with specified character class" {
  export PW_GEN_LENGTH=5
  export PW_GEN_CLASS="1"
  run pw -p gen 8 "2"
  assert_success
  assert_output "22222222"
}
