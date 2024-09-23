setup() {
  load 'macos_keychain'
  _setup
  pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

teardown() {
  _delete_keychain
}

assert_item_not_exists_output() {
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

assert_item_already_exists_output() {
  assert_output "security: SecKeychainItemCreateFromContent (${PW_KEYCHAIN}): The specified item already exists in the keychain."
}

assert_removes_item_output() {
  assert_output "password has been deleted."
}

assert_rm_not_found_output() {
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
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

@test "doesn't have item with name" {
  assert_item_not_exists "${NAME_A}"
}

@test "doesn't have item with account" {
  assert_item_not_exists "" "${ACCOUNT_A}"
}

@test "doesn't have item with name and account" {
  assert_item_not_exists "${NAME_A}" "${ACCOUNT_A}"
}

################################################################################
# add
################################################################################

@test "adds item with name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
}

@test "adds item with account" {
  assert_adds_item "${PW_1}" "" "${ACCOUNT_A}"
  assert_item_exists "${PW_1}" "" "${ACCOUNT_A}"
}

@test "adds item with name and account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "" "${ACCOUNT_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
}

################################################################################
# add another
################################################################################

@test "adds item with different name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"
}

@test "adds item with different account" {
  assert_adds_item "${PW_1}" "" "${ACCOUNT_A}"
  assert_adds_item "${PW_2}" "" "${ACCOUNT_B}"
  assert_item_exists "${PW_1}" "" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "" "${ACCOUNT_B}"
}

@test "adds item with different name and same account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"

  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"

  assert_item_exists "${PW_1}" "" "${ACCOUNT_A}"

  assert_item_exists "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
}

@test "adds item with same name and different account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_adds_item "${PW_2}" "${NAME_A}" "${ACCOUNT_B}"

  assert_item_exists "${PW_1}" "${NAME_A}"

  assert_item_exists "${PW_1}" "" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "" "${ACCOUNT_B}"

  assert_item_exists "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" "${ACCOUNT_B}"
}

################################################################################
# add duplicate
################################################################################

@test "fails when adding item with existing name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_already_exists "${PW_2}" "${NAME_A}"
}

@test "fails when adding item with existing account" {
  assert_adds_item "${PW_1}" "" "${ACCOUNT_A}"
  assert_item_already_exists "${PW_2}" "" "${ACCOUNT_A}"
}

@test "fails when adding item with existing name and account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_already_exists "${PW_2}" "${NAME_A}" "${ACCOUNT_A}"
}

################################################################################
# rm
################################################################################

@test "removes item with name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_removes_item "${NAME_A}"
  assert_item_not_exists "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"
}

@test "removes item with account" {
  assert_adds_item "${PW_1}" "" "${ACCOUNT_A}"
  assert_adds_item "${PW_2}" "" "${ACCOUNT_B}"
  assert_removes_item "" "${ACCOUNT_A}"
  assert_item_not_exists "" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "" "${ACCOUNT_B}"
}

@test "removes item with name and account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item "${PW_3}" "${NAME_A}" "${ACCOUNT_B}"
  assert_removes_item "${NAME_A}" "${ACCOUNT_A}"
  assert_item_not_exists "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_item_exists "${PW_3}" "${NAME_A}" "${ACCOUNT_B}"
}

################################################################################
# rm non existing item
################################################################################

@test "fails when deleting non existing item with name" {
  assert_rm_not_found "${NAME_A}"
}

@test "fails when deleting non existing item with account" {
  assert_rm_not_found "" "${ACCOUNT_A}"
}

@test "fails when deleting non existing item with name and account" {
  assert_rm_not_found "${NAME_A}" "${ACCOUNT_A}"
}

################################################################################
# edit
################################################################################

@test "edits item with name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_edits_item "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}"
}

@test "edits item with account" {
  assert_adds_item "${PW_1}" "" "${ACCOUNT_A}"
  assert_edits_item "${PW_2}" "" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "" "${ACCOUNT_A}"
}

@test "edits item with name and account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_edits_item "${PW_2}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" "${ACCOUNT_A}"
}

################################################################################
# edit non existing item
################################################################################

@test "adds item when editing non existing item with name" {
  assert_edits_item "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}"
}

@test "adds item when editing non existing item with account" {
  assert_edits_item "${PW_2}" "" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "" "${ACCOUNT_A}"
}

@test "adds item when editing non existing item with name and account" {
  assert_edits_item "${PW_2}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" "${ACCOUNT_A}"
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
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_B}"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
${NAME_A}                           	${ACCOUNT_A}
${NAME_B}                           	${ACCOUNT_B}
EOF
}

@test "ls handles <NULL> name" {
  assert_adds_item "${PW_1}" "" "${ACCOUNT_A}"
  run pw ls
  assert_success
  assert_output "                                        	${ACCOUNT_A}"
}

@test "ls handles <NULL> account" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw ls
  assert_success
  assert_output "${NAME_A}                           	"
}

@test "ls handles = in name" {
  assert_adds_item "${PW_1}" "te=st"
  run pw ls
  assert_success
  assert_output "te=st                                   	"
}
