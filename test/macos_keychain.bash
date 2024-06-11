load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'
load 'test_helper/bats-file/load.bash'

TEST_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_macos_keychain_test.keychain-db"

_setup() {
  security create-keychain -p pw_test_password "${TEST_KEYCHAIN}"
}

_teardown() {
  security delete-keychain "${TEST_KEYCHAIN}"
}

################################################################################
# get item
################################################################################

_get_item_with_name()             { security find-generic-password -s "$1"         -w "${TEST_KEYCHAIN}"; }
_get_item_with_account()          { security find-generic-password -a "$1"         -w "${TEST_KEYCHAIN}"; }
_get_item_with_name_and_account() { security find-generic-password -s "$1" -a "$2" -w "${TEST_KEYCHAIN}"; }

_assert_no_item() {
  assert_failure
  assert_output "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
}

################################################################################
# add item
################################################################################

_add_item_with_name()             { _add_item_with_name_and_account "$1" "" "$2"; }
_add_item_with_account()          { _add_item_with_name_and_account "" "$1" "$2"; }
_add_item_with_name_and_account() { security add-generic-password -s "$1" -a "$2" -w "$3" "${TEST_KEYCHAIN}"; }

_assert_fail_add_item() {
  assert_failure
  assert_output "security: SecKeychainItemCreateFromContent (${TEST_KEYCHAIN}): The specified item already exists in the keychain."
}

################################################################################
# delete item
################################################################################

_delete_item_with_name()             { security delete-generic-password -s "$1"         "${TEST_KEYCHAIN}"; }
_delete_item_with_account()          { security delete-generic-password -a "$1"         "${TEST_KEYCHAIN}"; }
_delete_item_with_name_and_account() { security delete-generic-password -s "$1" -a "$2" "${TEST_KEYCHAIN}"; }

################################################################################
# update item
################################################################################

_update_item_with_name()             { _update_item_with_name_and_account "$1" "" "$2"; }
_update_item_with_account()          { _update_item_with_name_and_account "" "$1" "$2"; }
_update_item_with_name_and_account() { security add-generic-password -U -s "$1" -a "$2" -w "$3" "${TEST_KEYCHAIN}"; }

################################################################################
# list items
################################################################################

_list_items() {
  local dump
  local -a names accounts name account
  dump="$(security dump-keychain "${TEST_KEYCHAIN}")"
  mapfile -t names < <(echo "${dump}" | grep "svce" | awk -F= '{print $2}' | tr -d \")
  mapfile -t accounts < <(echo "${dump}" | grep "acct" | awk -F= '{print $2}' | tr -d \")
  for ((i = 0; i < ${#names[@]}; i++)); do
    name="${names[i]}"
    account="${accounts[i]}"
    [[ "${name}" == "<NULL>" ]] && name=""
    [[ "${account}" == "<NULL>" ]] && account=""
    printf "%-40s\t%s\n" "${name}" "${account}"
  done | LC_ALL=C sort
}
