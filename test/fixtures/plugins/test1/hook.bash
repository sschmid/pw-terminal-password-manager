# shellcheck disable=SC2034
FILE_TYPE="Test File Type 1"
FILE_EXTENSION="test-keychain-1"

register() {
  [[ -v PW_TEST_PLUGIN_1 ]]
}

register_with_extension() {
  [[ -v PW_TEST_PLUGIN_1 ]]
}
