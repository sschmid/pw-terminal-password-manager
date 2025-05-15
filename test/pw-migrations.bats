# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup
  local keychain="${BATS_TEST_TMPDIR}/test keychain.test"
  touch "${keychain}"
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

_set_pw_config_11_0_0() {
  # moved to ~/.config/pw/config
  cat << EOF > "${PW_CONFIG}"
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
  run pw -y ls
  assert_failure

  run cat "${PW_CONFIG}"
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

@test "migrates pwrc from <9.0.0 to latest" {
  _set_pwrc_before_9_0_0 "${keychain}"
  assert_latest_pwrc "${keychain}"
}

@test "migrates pwrc from <10.0.0 to latest" {
  _set_pwrc_9_0_0 "${keychain}"
  assert_latest_pwrc "${keychain}"
}

@test "migrates pwrc from <11.0.0 to latest" {
  _set_pwrc_10_0_0 "${keychain}"
  assert_latest_pwrc "${keychain}"
}

@test "ignores latest" {
  _set_pw_config_11_0_0 "${keychain}"
  assert_latest_pwrc "${keychain}"
}
