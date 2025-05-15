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

@test "doesn't source config" {
  _config_append_keychains " test keychain "
  echo 'echo "# test config sourced"' >> "${PW_CONFIG}"
  run pw -h
  refute_output --partial "# test config sourced"
}

@test "doesn't create default config when not accessed" {
  run pw -h
  assert_file_not_exists "${PW_CONFIG}"
}

@test "creates default config" {
  run pw ls
  assert_file_exists "${PW_CONFIG}"
}

@test "doesn't create custom config" {
  run pw -c "${BATS_TEST_TMPDIR}/myconfig" ls
  assert_file_not_exists "${PW_CONFIG}"
}

@test "uses custom config" {
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/test keychain.test"
  _set_config_with_test_plugins "${BATS_TEST_TMPDIR}/myconfig"
  run pw -c "${BATS_TEST_TMPDIR}/myconfig" ls
  assert_success
  assert_output "test ls <> <> <${PW_KEYCHAIN}> <default>"
}

@test "exits when invalid option" {
  run pw -x -h
  assert_failure
  assert_output "Invalid option: -x"
}

@test "generates and prints password" {
  export PW_GEN_LENGTH=1
  export PW_GEN_CLASS="1"
  run pw -p gen
  assert_success
  assert_output "1"
}

@test "generates password with specified length" {
  export PW_GEN_LENGTH=2
  export PW_GEN_CLASS="1"
  run pw -p gen 1
  assert_success
  assert_output "1"
}

@test "generates password with specified character class" {
  export PW_GEN_LENGTH=2
  export PW_GEN_CLASS="1"
  run pw -p gen 1 "2"
  assert_success
  assert_output "2"
}

# @test "BusyBox: replaces [:graph:] with [:alnum:][:punct:]" {
#   export PW_GEN_LENGTH=64
#   export PW_GEN_CLASS="[:graph:]"
#   run pw -p gen
#   assert_success
#   assert_output "check manually"
# }

# @test "alpine: replaces [:print:] with [:alnum:][:punct:][:space:]" {
#   export PW_GEN_LENGTH=64
#   export PW_GEN_CLASS="[:print:]"
#   run pw -p gen
#   assert_success
#   assert_output "check manually"
# }
