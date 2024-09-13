# shellcheck disable=SC2034
FILE_TYPE="Test File Type 2"
FILE_EXTENSION="ext2"

pw::register() {
  [[ -v PW_TEST_PLUGIN_2 ]]
}

pw::register_with_extension() {
  [[ -v PW_TEST_PLUGIN_2 ]]
}
