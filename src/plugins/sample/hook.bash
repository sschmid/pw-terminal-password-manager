# This is a sample hook that you can copy and paste as a template for your own plugins.
# This sample hook is ignored by pw and will not be loaded.
FILE_TYPE="Put the file type here. Use 'file -b <file>' to get it, e.g. 'file -b my-keychain.xyz'"
FILE_EXTENSION="Put the file extension here. e.g. 'xyz'"

# This function is called by pw to discover keychains.
# Typically, you would list all keychains in the current directory.
pw::discover_keychains() {
  local filetype
  while read -r path; do
    filetype="$(file -b "${path}")"
    [[ "${filetype}" != "${FILE_TYPE}" ]] || echo "${path}"
  done < <(find "${PWD}" -type f -maxdepth 1)
}

# This function is called by pw to try to register this plugin for a given file type.
# If your plugin can handle the file type, return 0, otherwise return 1.
# It's a good idea to check if the file exists and if it's the correct type.
# Checking if the file exists may make sense for certain password managers like
# macOS Keychain, because it supports not only file paths but also keychain names
# which it can look up in different locations.
# Add other checks as needed.
pw::register() {
  [[ -f "${PW_KEYCHAIN}" ]]
  [[ "$(file -b "${PW_KEYCHAIN}")" == "${FILE_TYPE}" ]]
}

# This function is called by pw to try to register this plugin for a given file extension.
# This is only called when creating a new keychain with 'pw init my-keychain.xyz'.
# As the file doesn't exist yet and is yet to be created, we can't check the file type.
# If your plugin can handle the file extension, return 0, otherwise return 1.
pw::register_with_extension() {
  [[ "$1" == "${FILE_EXTENSION}" ]]
}
