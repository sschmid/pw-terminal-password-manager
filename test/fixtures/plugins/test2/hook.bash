# shellcheck disable=SC2034
FILE_TYPE="Test File Type 2"
FILE_EXTENSION="test-keychain-2"

register() {
  [[ -v PW_TEST_PLUGIN_2 ]]
}

register_with_extension() {
  [[ -v PW_TEST_PLUGIN_2 ]]
}
