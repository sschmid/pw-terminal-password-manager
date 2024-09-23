# shellcheck disable=SC2034
FILE_TYPE="Test File Type 1"
FILE_EXTENSION="ext1"

pw::discover_keychains() { :; }

pw::register() {
  [[ -v PW_TEST_PLUGIN_1 ]]
}

pw::register_with_extension() {
  [[ -v PW_TEST_PLUGIN_1 ]]
}
