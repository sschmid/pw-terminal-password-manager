# shellcheck disable=SC2034
FILE_TYPE="Test File Type Fail"
FILE_EXTENSION="extf"

pw::discover_keychains() { :; }

pw::register() {
  [[ -v PW_TEST_PLUGIN_FAIL ]]
}

pw::register_with_extension() {
  [[ -v PW_TEST_PLUGIN_FAIL ]]
}
