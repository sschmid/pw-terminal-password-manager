_setup() {
  load 'test-helper'
  _common_setup
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw keepassxc test.kdbx"
}

_delete_keychain() {
  rm -f "${PW_KEYCHAIN}"
}
