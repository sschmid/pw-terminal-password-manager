setup() {
  load 'macos_keychain'
  _setup
  pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"

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
  run pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_failure
  assert_output "pw: ${PW_KEYCHAIN}: File already exists"
}

################################################################################
# get
################################################################################

assert_item_exists() {
  local password="$1"; shift
  run pw -p "$@"
  assert_success
  assert_output "${password}"
}

assert_item_not_exists() {
  run pw "$@"
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
  local password="$1"; shift
  run pw add "$@" <<< "${password}"
  assert_success
  refute_output
}

@test "adds item with name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_item_exists "${pw1}" "${nameA}"
}

@test "adds item with account" {
  assert_adds_item "${pw1}" "" "${accountA}"
  assert_item_exists "${pw1}" "" "${accountA}"
}

@test "adds item with name and account" {
  assert_adds_item "${pw1}" "${nameA}" "${accountA}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw1}" "" "${accountA}"
  assert_item_exists "${pw1}" "${nameA}" "${accountA}"
}

################################################################################
# add another
################################################################################

@test "adds item with different name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_adds_item "${pw2}" "${nameB}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

@test "adds item with different account" {
  assert_adds_item "${pw1}" "" "${accountA}"
  assert_adds_item "${pw2}" "" "${accountB}"
  assert_item_exists "${pw1}" "" "${accountA}"
  assert_item_exists "${pw2}" "" "${accountB}"
}

@test "adds item with different name and same account" {
  assert_adds_item "${pw1}" "${nameA}" "${accountA}"
  assert_adds_item "${pw2}" "${nameB}" "${accountA}"

  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"

  assert_item_exists "${pw1}" "" "${accountA}"

  assert_item_exists "${pw1}" "${nameA}" "${accountA}"
  assert_item_exists "${pw2}" "${nameB}" "${accountA}"
}

@test "adds item with same name and different account" {
  assert_adds_item "${pw1}" "${nameA}" "${accountA}"
  assert_adds_item "${pw2}" "${nameA}" "${accountB}"

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
  local password="$1"; shift
  run pw add "$@" <<< "${password}"
  assert_failure
  assert_output "security: SecKeychainItemCreateFromContent (${PW_KEYCHAIN}): The specified item already exists in the keychain."
}

@test "fails when adding item with existing name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_item_already_exists "${pw2}" "${nameA}"
}

@test "fails when adding item with existing account" {
  assert_adds_item "${pw1}" "" "${accountA}"
  assert_item_already_exists "${pw2}" "" "${accountA}"
}

@test "fails when adding item with existing name and account" {
  assert_adds_item "${pw1}" "${nameA}" "${accountA}"
  assert_item_already_exists "${pw2}" "${nameA}" "${accountA}"
}

################################################################################
# rm
################################################################################

assert_removes_item() {
  run pw rm "$@"
  assert_success
  assert_output "password has been deleted."
}

@test "removes item with name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_adds_item "${pw2}" "${nameB}"
  assert_removes_item "${nameA}"
  assert_item_not_exists "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

@test "removes item with account" {
  assert_adds_item "${pw1}" "" "${accountA}"
  assert_adds_item "${pw2}" "" "${accountB}"
  assert_removes_item "" "${accountA}"
  assert_item_not_exists "" "${accountA}"
  assert_item_exists "${pw2}" "" "${accountB}"
}

@test "removes item with name and account" {
  assert_adds_item "${pw1}" "${nameA}" "${accountA}"
  assert_adds_item "${pw2}" "${nameB}" "${accountA}"
  assert_adds_item "${pw3}" "${nameA}" "${accountB}"
  assert_removes_item "${nameA}" "${accountA}"
  assert_item_not_exists "${accountA}" "${accountA}"
  assert_item_exists "${pw2}" "${nameB}" "${accountA}"
  assert_item_exists "${pw3}" "${nameA}" "${accountB}"
}

################################################################################
# rm non existing item
################################################################################

assert_rm_not_found() {
  run pw rm "$@"
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
  local password="$1"; shift
  run pw edit "$@" <<< "${password}"
  assert_success
  refute_output
}

@test "edits item with name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_edits_item "${pw2}" "${nameA}"
  assert_item_exists "${pw2}" "${nameA}"
}

@test "edits item with account" {
  assert_adds_item "${pw1}" "" "${accountA}"
  assert_edits_item "${pw2}" "" "${accountA}"
  assert_item_exists "${pw2}" "" "${accountA}"
}

@test "edits item with name and account" {
  assert_adds_item "${pw1}" "${nameA}" "${accountA}"
  assert_edits_item "${pw2}" "${nameA}" "${accountA}"
  assert_item_exists "${pw2}" "${nameA}" "${accountA}"
}

################################################################################
# edit non existing item
################################################################################

@test "adds item when editing non existing item with name" {
  assert_edits_item "${pw2}" "${nameA}"
  assert_item_exists "${pw2}" "${nameA}"
}

@test "adds item when editing non existing item with account" {
  assert_edits_item "${pw2}" "" "${accountA}"
  assert_item_exists "${pw2}" "" "${accountA}"
}

@test "adds item when editing non existing item with name and account" {
  assert_edits_item "${pw2}" "${nameA}" "${accountA}"
  assert_item_exists "${pw2}" "${nameA}" "${accountA}"
}

################################################################################
# list item
################################################################################

@test "lists no items" {
  run pw ls
  assert_success
  refute_output
}

@test "lists sorted items" {
  assert_adds_item "${pw2}" "${nameB}" "${accountB}"
  assert_adds_item "${pw1}" "${nameA}" "${accountA}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
${nameA}                           	${accountA}
${nameB}                           	${accountB}
EOF
}

@test "ls handles <NULL> name" {
  assert_adds_item "${pw1}" "" "${accountA}"
  run pw ls
  assert_success
  assert_output "                                        	${accountA}"
}

@test "ls handles <NULL> account" {
  assert_adds_item "${pw1}" "${nameA}"
  run pw ls
  assert_success
  assert_output "${nameA}                           	"
}

@test "ls handles = in name" {
  assert_adds_item "${pw1}" "te=st"
  run pw ls
  assert_success
  assert_output "te=st                                   	"
}
