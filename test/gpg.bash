_setup() {
  load 'test-helper'
  _common_setup
  export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_gpg_test"
  source "${PROJECT_ROOT}/src/plugins/gpg/plugin.bash"
}

_delete_keychain() {
  rm -rf "${PW_KEYCHAIN}"
}
