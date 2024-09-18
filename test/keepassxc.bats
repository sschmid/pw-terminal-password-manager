setup() {
  load 'keepassxc'
  _setup
  declare -Ag PW_KEYCHAIN_ARGS=()
  PW_KEEPASSXC_PASSWORD=" test password "
  pw::plugin_init <<< "${PW_KEEPASSXC_PASSWORD}"

  nameA=" a test name "
  nameB=" b test name "
  accountA=" a test account "
  pw1=" 1 test pw "
  pw2=" 2 test pw "
}

# shellcheck disable=SC2034
_init_with_key_file() {
  local path="${BATS_TEST_TMPDIR}/pw_keepassxc_test_keyfile.kdbx"
  echo "pw_keepassxc_test_keyfile" > "${path}"
  PW_KEYCHAIN_ARGS["keyfile"]="${path}"
  PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_keepassxc_test_with_keyfile.kdbx"
  pw::plugin_init <<< "${PW_KEEPASSXC_PASSWORD}"
}

teardown() {
  _delete_keychain
}

################################################################################
# init
################################################################################

@test "init fails when keychain already exists" {
  run pw::plugin_init <<< "${PW_KEEPASSXC_PASSWORD}"
  assert_failure
  assert_output "File ${PW_KEYCHAIN} already exists."
}

@test "inits keychain with key-file" {
  _init_with_key_file
  assert_item_not_exists "${nameA}"
}

################################################################################
# get
################################################################################

assert_item_exists() {
  local password="$1"; shift
  run pw::plugin_get "$@"
  assert_success
  assert_output "${password}"
}

assert_item_not_exists() {
  run pw::plugin_get "$@"
  assert_failure
  assert_output "Could not find entry with path $1."
}

assert_item_recycled() {
  local password="$1"; shift
  run pw::plugin_get "/Recycle Bin/$1"
  assert_success
  assert_output "${password}"
}

@test "doesn't have item" {
  assert_item_not_exists "${nameA}"
}

@test "get with key-file" {
  _init_with_key_file
  assert_item_not_exists "${nameA}"
}

################################################################################
# add
################################################################################

assert_adds_item() {
  run pw::plugin_add "$@"
  assert_success
  refute_output
}

assert_username() {
  run keepassxc-cli show -qsa username "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
  assert_success
  if (($# == 2))
  then assert_output "$2"
  else refute_output
  fi
}

@test "adds item with name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_username "${nameA}"
}

@test "adds item with name and account" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_username "${nameA}" "${accountA}"
}

@test "adds item with key-file" {
  _init_with_key_file
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}"
}

################################################################################
# add another
################################################################################

@test "adds item with different name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_adds_item "${nameB}" "" "${pw2}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

################################################################################
# add duplicate
################################################################################

@test "fails when adding item with existing name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_add "${nameA}" "" "${pw2}"
  assert_failure
  assert_output "Could not create entry with path ${nameA}."
}

################################################################################
# rm
################################################################################

@test "removes item" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_adds_item "${nameB}" "" "${pw2}"
  run pw::plugin_rm "${nameA}"
  assert_success
  refute_output
  assert_item_recycled "${pw1}" "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

@test "removes item with key-file" {
  _init_with_key_file
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_rm "${nameA}"
  assert_success
  refute_output
}

################################################################################
# rm non existing item
################################################################################

@test "fails when deleting non existing item" {
  run pw::plugin_rm "${nameA}"
  assert_failure
  assert_output "Entry ${nameA} not found."
}

################################################################################
# edit
################################################################################

@test "edits item" {
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_edit "${nameA}" "" "${pw2}"
  assert_success
  refute_output
  assert_item_exists "${pw2}" "${nameA}"
}

@test "edits item with key-file" {
  _init_with_key_file
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_edit "${nameA}" "" "${pw2}"
  assert_success
  refute_output
}

################################################################################
# edit non existing item
################################################################################

@test "fails when editing non existing item" {
  run pw::plugin_edit "${nameA}" "" "${pw2}"
  assert_failure
  assert_output "Could not find entry with path ${nameA}."
}

################################################################################
# list item
################################################################################

@test "lists no items" {
  run pw::plugin_ls
  assert_success
  refute_output
}

@test "lists sorted items" {
  assert_adds_item "${nameB}" "${accountA}" "${pw2}"
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  run pw::plugin_ls
  assert_success
  cat << EOF | assert_output -
${nameA}
${nameB}
EOF
}

@test "filters Recycle Bin/" {
  assert_adds_item "${nameB}" "${accountA}" "${pw2}"
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  run pw::plugin_rm "${nameA}"
  run pw::plugin_ls
  assert_success
  cat << EOF | assert_output -
${nameB}
EOF
}

@test "lists no items after filtering" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  run pw::plugin_rm "${nameA}"
  run pw::plugin_ls
  assert_success
  refute_output
}

@test "lists sorted items with key-file" {
  _init_with_key_file
  assert_adds_item "${nameB}" "${accountA}" "${pw2}"
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  run pw::plugin_ls
  assert_success
  cat << EOF | assert_output -
${nameA}
${nameB}
EOF
}
