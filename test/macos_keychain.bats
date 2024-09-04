setup() {
  load 'macos_keychain'
  _setup
  pw::plugin_init <<< " test password "

  nameA=" a test name "
  nameB=" b test name "
  accountA=" a test account "
  accountB=" b test account "
  pw1=" 1 test pw "
  pw2=" 2 test pw "
  pw3=" 3 test pw "
}

teardown() {
  _delete_keychain
}

################################################################################
# init
################################################################################

@test "init fails when keychain already exists" {
  run pw::plugin_init <<< " test password "
  assert_failure
  assert_output "security: SecKeychainCreate ${PW_KEYCHAIN}: A keychain with the same name already exists."
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
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

@test "doesn't have item with name" {
  assert_item_not_exists "${nameA}"
}

@test "doesn't have item with account" {
  assert_item_not_exists "" "${accountA}"
}

@test "doesn't have item with name and account" {
  assert_item_not_exists "${nameA}" "${accountA}"
}

################################################################################
# add
################################################################################

assert_adds_item() {
  run pw::plugin_add "$@"
  assert_success
  refute_output
}

@test "adds item with name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}"
}

@test "adds item with account" {
  assert_adds_item "" "${accountA}" "${pw1}"
  assert_item_exists "${pw1}" "" "${accountA}"
}

@test "adds item with name and account" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw1}" "" "${accountA}"
  assert_item_exists "${pw1}" "${nameA}" "${accountA}"
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

@test "adds item with different account" {
  assert_adds_item "" "${accountA}" "${pw1}"
  assert_adds_item "" "${accountB}" "${pw2}"
  assert_item_exists "${pw1}" "" "${accountA}"
  assert_item_exists "${pw2}" "" "${accountB}"
}

@test "adds item with different name and same account" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  assert_adds_item "${nameB}" "${accountA}" "${pw2}"

  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"

  assert_item_exists "${pw1}" "" "${accountA}"

  assert_item_exists "${pw1}" "${nameA}" "${accountA}"
  assert_item_exists "${pw2}" "${nameB}" "${accountA}"
}

@test "adds item with same name and different account" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  assert_adds_item "${nameA}" "${accountB}" "${pw2}"

  assert_item_exists "${pw1}" "${nameA}"

  assert_item_exists "${pw1}" "" "${accountA}"
  assert_item_exists "${pw2}" "" "${accountB}"

  assert_item_exists "${pw1}" "${nameA}" "${accountA}"
  assert_item_exists "${pw2}" "${nameA}" "${accountB}"
}

################################################################################
# add duplicate
################################################################################

assert_item_already_exists() {
  run pw::plugin_add "$@"
  assert_failure
  assert_output "security: SecKeychainItemCreateFromContent (${PW_KEYCHAIN}): The specified item already exists in the keychain."
}

@test "fails when adding item with existing name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_item_already_exists "${nameA}" "" "${pw2}"
}

@test "fails when adding item with existing account" {
  assert_adds_item "" "${accountA}" "${pw1}"
  assert_item_already_exists "" "${accountA}" "${pw2}"
}

@test "fails when adding item with existing name and account" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  assert_item_already_exists "${nameA}" "${accountA}" "${pw2}"
}

################################################################################
# rm
################################################################################

assert_removes_item() {
  run pw::plugin_rm "$@"
  assert_success
  assert_output "password has been deleted."
}

@test "removes item with name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_adds_item "${nameB}" "" "${pw2}"
  assert_removes_item "${nameA}"
  assert_item_not_exists "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

@test "removes item with account" {
  assert_adds_item "" "${accountA}" "${pw1}"
  assert_adds_item "" "${accountB}" "${pw2}"
  assert_removes_item "" "${accountA}"
  assert_item_not_exists "" "${accountA}"
  assert_item_exists "${pw2}" "" "${accountB}"
}

@test "removes item with name and account" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  assert_adds_item "${nameB}" "${accountA}" "${pw2}"
  assert_adds_item "${nameA}" "${accountB}" "${pw3}"
  assert_removes_item "${nameA}" "${accountA}"
  assert_item_not_exists "${accountA}" "${accountA}"
  assert_item_exists "${pw2}" "${nameB}" "${accountA}"
  assert_item_exists "${pw3}" "${nameA}" "${accountB}"
}

################################################################################
# rm non existing item
################################################################################

assert_rm_not_found() {
  run pw::plugin_rm "$@"
  assert_failure
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

@test "fails when deleting non existing item with name" {
  assert_rm_not_found "${nameA}"
}

@test "fails when deleting non existing item with account" {
  assert_rm_not_found "" "${accountA}"
}

@test "fails when deleting non existing item with name and account" {
  assert_rm_not_found "${nameA}" "${accountA}"
}

################################################################################
# edit
################################################################################

assert_edits_item() {
  run pw::plugin_edit "$@"
  assert_success
  refute_output
}

@test "edits item with name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_edits_item "${nameA}" "" "${pw2}"
  assert_item_exists "${pw2}" "${nameA}"
}

@test "edits item with account" {
  assert_adds_item "" "${accountA}" "${pw1}"
  assert_edits_item "" "${accountA}" "${pw2}"
  assert_item_exists "${pw2}" "" "${accountA}"
}

@test "edits item with name and account" {
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  assert_edits_item "${nameA}" "${accountA}" "${pw2}"
  assert_item_exists "${pw2}" "${nameA}" "${accountA}"
}

################################################################################
# edit non existing item
################################################################################

@test "adds item when editing non existing item with name" {
  assert_edits_item "${nameA}" "" "${pw2}"
  assert_item_exists "${pw2}" "${nameA}"
}

@test "adds item when editing non existing item with account" {
  assert_edits_item "" "${accountA}" "${pw2}"
  assert_item_exists "${pw2}" "" "${accountA}"
}

@test "adds item when editing non existing item with name and account" {
  assert_edits_item "${nameA}" "${accountA}" "${pw2}"
  assert_item_exists "${pw2}" "${nameA}" "${accountA}"
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
  assert_adds_item "${nameB}" "${accountB}" "${pw2}"
  assert_adds_item "${nameA}" "${accountA}" "${pw1}"
  run pw::plugin_ls
  assert_success
  cat << EOF | assert_output -
${nameA}                           	${accountA}
${nameB}                           	${accountB}
EOF
}

@test "ls handles <NULL> name" {
  assert_adds_item "" "${accountA}" "${pw1}"
  run pw::plugin_ls
  assert_success
  assert_output "                                        	${accountA}"
}

@test "ls handles <NULL> account" {
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_ls
  assert_success
  assert_output "${nameA}                           	"
}

@test "ls handles = in name" {
  assert_adds_item "te=st" "" "${pw1}"
  run pw::plugin_ls
  assert_success
  assert_output "te=st                                   	"
}
