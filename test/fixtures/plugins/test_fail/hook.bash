# shellcheck disable=SC2034
FILE_TYPE="Test File Type Fail"
FILE_EXTENSION="test-keychain-fail"

register() {
  [[ -v PW_TEST_PLUGIN_FAIL ]]
}

register_with_extension() {
  [[ -v PW_TEST_PLUGIN_FAIL ]]
}
