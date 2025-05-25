# shellcheck disable=SC2030,SC2031
setup() {
  load 'pw'
  _setup

  # PW_RC is depricated. Keep for migration tests.
  export PW_RC="${BATS_TEST_TMPDIR}/pwrc"

  # .config/pw/config is depricated. Keep for migration tests.
  PW_CONFIG_11="${XDG_CONFIG_HOME}/pw/config"

  keychain="${BATS_TEST_TMPDIR}/test keychain.test"
  touch "${keychain}"
}

_set_pwrc_before_9_0_0() {
  # using PW_KEYCHAINS array format
  echo "PW_KEYCHAINS=('${keychain}')" > "${PW_RC}"
}

_set_pwrc_9_0_0() {
  # using keychain path format
  echo "${keychain}" > "${PW_RC}"
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
	${keychain}
EOF
}

_set_pw_config_11_0_0() {
  # moved to ~/.config/pw/config
  cat << EOF > "${PW_CONFIG_11}"
[config]
	password_length = 35
	password_character_class = [:graph:]
	clipboard_clear_time = 45

[plugins]
	\$PW_HOME/plugins/gpg
	\$PW_HOME/plugins/keepassxc
	\$PW_HOME/plugins/macos_keychain

[keychains]
	${keychain}
EOF
}

_set_pw_config_12_0_0() {
  # moved to ~/.config/pw/pw.conf
  cat << EOF > "${PW_CONFIG}"
[general]
password_length = 35
password_character_class = [:graph:]
clipboard_clear_time = 45

[plugins]
plugin = \$PW_HOME/plugins/gpg
plugin = \$PW_HOME/plugins/keepassxc
plugin = \$PW_HOME/plugins/macos_keychain

[keychains]
keychain = ${keychain}
EOF
}

assert_latest_config() {
  run pw -y ls
  assert_failure

  run cat "${PW_CONFIG}"
  assert_success
  cat << EOF | assert_output -
[general]
password_length = 35
password_character_class = [:graph:]
clipboard_clear_time = 45

[plugins]
plugin = \$PW_HOME/plugins/gpg
plugin = \$PW_HOME/plugins/keepassxc
plugin = \$PW_HOME/plugins/macos_keychain

[keychains]
keychain = ${keychain}
EOF
}

@test "migrates pwrc from <9.0.0 to latest config" {
  _set_pwrc_before_9_0_0
  assert_latest_config
}

@test "migrates pwrc from <10.0.0 to latest config" {
  _set_pwrc_9_0_0
  assert_latest_config
}

@test "migrates pwrc from <11.0.0 to latest config" {
  _set_pwrc_10_0_0
  assert_latest_config
}

@test "migrates pwrc from <12.0.0 to latest config" {
  _set_pw_config_11_0_0
  assert_latest_config
}

@test "ignores latest" {
  _set_pw_config_12_0_0
  assert_latest_config
}
