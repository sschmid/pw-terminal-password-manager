# shellcheck disable=SC2034
FILE_TYPE="Test File Type Modify"
FILE_EXTENSION="extm"

export PW_TEST_PLUGIN_FAIL=1
PW_KEYCHAIN+=" #modified-soure"

pw::discover_keychains() {
  PW_KEYCHAIN+=" #modified-${FUNCNAME[0]}"
}

pw::register() {
  PW_KEYCHAIN+=" #modified-${FUNCNAME[0]}"
  return 1
}

pw::register_with_extension() {
  PW_KEYCHAIN+=" #modified-${FUNCNAME[0]}"
  return 1
}
