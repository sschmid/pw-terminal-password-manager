_setup() {
	load 'test-helper'
	_common_setup
	export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw macos_keychain test.keychain-db"
}

_delete_keychain() {
	security delete-keychain "${PW_KEYCHAIN}"
}

_config_append_macos_keychain_keychain_access_control_always_allow() {
	cat >> "${PW_CONFIG}" << EOF
[macos_keychain]
keychain_access_control = always-allow
EOF
}

_config_append_macos_keychain_keychain_access_control_confirm() {
	cat >> "${PW_CONFIG}" << EOF
[macos_keychain]
keychain_access_control = confirm
EOF
}
