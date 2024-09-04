_setup() {
  load 'test-helper'
  _common_setup
}

_set_pwrc_with_keychains() {
  export PW_RC="${BATS_TEST_TMPDIR}/pwrc.bash"
  echo "PW_KEYCHAINS=($1)" > "${PW_RC}"
}
