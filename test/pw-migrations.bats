# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
}

_set_pwrc_before_9_0_0() {
  # using PW_KEYCHAINS array format
  echo "PW_KEYCHAINS=('$1')" > "${PW_RC}"
}

_set_pwrc_9_0_0() {
  # using keychain path format
  echo "$1" > "${PW_RC}"
}

_set_pwrc_10_0_0() {
  # using ini-like format
  cat << EOF > "${PW_RC}"
[config]
	password_length = 35
	password_character_class = [:graph:]
	clipboard_clear_time = 45

[plugins]
	\$PW_HOME/plugins/gpg
	\$PW_HOME/plugins/keepassxc
	\$PW_HOME/plugins/macos_keychain

[keychains]
	$1
EOF
}

assert_latest_pwrc() {
  run cat "${PW_RC}"
  assert_success
  cat << EOF | assert_output -
[config]
	password_length = 35
	password_character_class = [:graph:]
	clipboard_clear_time = 45

[plugins]
	\$PW_HOME/plugins/gpg
	\$PW_HOME/plugins/keepassxc
	\$PW_HOME/plugins/macos_keychain

[keychains]
	$1
EOF
}

# bats test_tags=tag:manual_test
@test "migrates pwrc to 9.0.0, then to 10.0.0" {
  _skip_manual_test "'y' twice"
  local keychain="${BATS_TEST_TMPDIR}/test keychain.test"
  touch "${keychain}"
  _set_pwrc_before_9_0_0 "${keychain}"

  run pw ls
  assert_failure
  assert_output --partial "pw 9.0.0 introduced a new .pwrc format. Would you like to automatically upgrade your .pwrc file? (y / N): "
  assert_output --partial "pw 10.0.0 introduced a new .pwrc format. Would you like to automatically upgrade your .pwrc file? (y / N): "

  assert_latest_pwrc "${keychain}"
}

# bats test_tags=tag:manual_test
@test "migrates pwrc to 10.0.0" {
  _skip_manual_test "'y'"
  local keychain="${BATS_TEST_TMPDIR}/test keychain.test"
  touch "${keychain}"
  _set_pwrc_9_0_0 "${keychain}"

  run pw ls
  assert_failure
  assert_output --partial "pw 10.0.0 introduced a new .pwrc format. Would you like to automatically upgrade your .pwrc file? (y / N): "

  assert_latest_pwrc "${keychain}"
}

@test "ignores latest pwrc" {
  local keychain="${BATS_TEST_TMPDIR}/test keychain.test"
  touch "${keychain}"
  _set_pwrc_10_0_0 "${keychain}"

  run pw ls
  assert_failure
  refute_output --partial "pw 9.0.0"
  refute_output --partial "pw 10.0.0"

  assert_latest_pwrc "${keychain}"
}
