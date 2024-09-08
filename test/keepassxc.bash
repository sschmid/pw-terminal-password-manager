_setup() {
  load 'test-helper'
  _common_setup
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_keepassxc_test.kdbx"
  source "${PROJECT_ROOT}/src/plugins/keepassxc/plugin.bash"
}

_delete_keychain() {
  rm -f "${PW_KEYCHAIN}"
}
