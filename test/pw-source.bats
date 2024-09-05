setup() {
  load 'pw'
  _setup
}

_source_pw() {
  # shellcheck disable=SC1090
  source "${1:-"${PROJECT_ROOT}/src/pw"}"
}

assert_bash_version_fail() {
  BASH_VERSION="$1" run pw::require_bash_version
  assert_failure
  cat << EOF | assert_output -
pw requires bash-4.2 or later. Installed: $1
Please install a newer version of bash.
EOF
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

assert_pw_home() {
  assert_equal "${PW_HOME}" "${PROJECT_ROOT}"
}

@test "resolves pw home" {
  _source_pw
  assert_pw_home
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

_intercept_prompt_password() {
  pw::prompt_password "name"
  echo "${PW_PASSWORD}"
}

@test "reads item password from stdin" {
  _source_pw
  run _intercept_prompt_password <<< "stdin test"
  assert_success
  assert_output "stdin test"
}

@test "prompts item password when no stdin" {
  _skip_manual_test "test" "twice"
  _source_pw
  run _intercept_prompt_password
  assert_success
  cat << EOF | assert_output -
Enter password for name:
Retype password for name:
test
EOF
}

@test "prompts and fails if retyped password does not match" {
  _skip_manual_test "test1" "and 'test2'"
  _source_pw
  run _intercept_prompt_password
  assert_failure
  cat << EOF | assert_output -
Enter password for name:
Retype password for name:
Error: the entered passwords do not match.
EOF
}

@test "generates password when empty" {
  _skip_manual_test "nothing"
  _source_pw
  run _intercept_prompt_password
  assert_success
  assert_line --index 0 "Enter password for name:"
  (("${#lines[1]}" == "${PW_GEN_LENGTH}"))
}

_intercept_prompt_keychain_password() {
  pw::prompt_keychain_password
  echo "${PW_KEYCHAIN_PASSWORD}"
}

@test "reads keychain password from stdin" {
  _source_pw
  run _intercept_prompt_keychain_password <<< "stdin test"
  assert_success
  assert_output "stdin test"
}

@test "prompts keychain password when no stdin" {
  _skip_manual_test "test"
  _source_pw
  run _intercept_prompt_keychain_password
  assert_success
  cat << EOF | assert_output -
Please enter the keychain password:
test
EOF
}

@test "prompts keychain password only once" {
  _skip_manual_test "test"
  _source_pw
  pw::prompt_keychain_password
  run _intercept_prompt_keychain_password
  assert_success
  assert_output "test"
}

@test "skips prompt when PW_KEYCHAIN_PASSWORD is set" {
  _source_pw
  export PW_KEYCHAIN_PASSWORD="env test"
  run _intercept_prompt_keychain_password
  assert_success
  assert_output "env test"
}

@test "ignores sample plugin" {
  _source_pw
  run pw::plugins
  assert_output --partial "macos_keychain/hook.bash"
  assert_output --partial "keepassxc/hook.bash"

  refute_output --partial "sample/hook.bash"
}