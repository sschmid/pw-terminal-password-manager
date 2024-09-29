_setup() {
  load 'test-helper'
  _common_setup
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_macos_keychain test.keychain-db"
}

_delete_keychain() {
  security delete-keychain "${PW_KEYCHAIN}"
}
