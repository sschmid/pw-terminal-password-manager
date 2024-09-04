_setup() {
  load 'test-helper'
  _common_setup
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_macos_keychain_test.keychain-db"
  source "${PROJECT_ROOT}/src/plugins/macos_keychain/plugin.bash"
}

_delete_keychain() {
  security delete-keychain "${PW_KEYCHAIN}"
}
