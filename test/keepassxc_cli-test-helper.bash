load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'
load 'test_helper/bats-file/load.bash'

: "${PW_KEEPASSXC:="/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli"}"
TEST_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_test.kdbx"
TEST_PASSWORD="pw_test_password"

_setup() {
  rm -f "${TEST_KEYCHAIN}"
  echo -ne "${TEST_PASSWORD}\n${TEST_PASSWORD}\n" \
  | "${PW_KEEPASSXC}" db-create -qp "${TEST_KEYCHAIN}"
}

_teardown() {
  rm -f "${TEST_KEYCHAIN}"
}

_not_implemented() {
  echo "Not implemented"
  return 1
}

_add_item_with_name() { _add_item_with_name_and_account "$1" "" "$2"; }
_add_item_with_account() { _not_implemented; }
_add_item_with_name_and_account() {
  run _pp_add_item_with_name_and_account "$@"
  assert_success
}
_pp_add_item_with_name_and_account() {
  local item_name="$1" item_account="$2" item_pw="$3"
  echo -ne "${TEST_PASSWORD}\n${item_pw}\n" | "${PW_KEEPASSXC}" add -qp "${TEST_KEYCHAIN}" -u "${item_account}" "${item_name}"
}

_update_item_with_name() { _update_item_with_name_and_account "$1" "" "$2"; }
_update_item_with_account() { _not_implemented; }
_update_item_with_name_and_account() {
  run _pp_update_item_with_name "$@"
  assert_success
}
_pp_update_item_with_name() {
  local item_name="$1" item_pw="$3"
  echo -ne "${TEST_PASSWORD}\n${item_pw}\n" | "${PW_KEEPASSXC}" edit -qp "${TEST_KEYCHAIN}" "${item_name}"
}

_delete_item_with_name() {
  run _pp__delete_item_with_name "$@"
  assert_success
}
_pp__delete_item_with_name() {
  local item_name="$1"
  "${PW_KEEPASSXC}" rm -q "${TEST_KEYCHAIN}" "${item_name}" <<< "${TEST_PASSWORD}"
}

_delete_item_with_account() {
  _not_implemented
}

_delete_item_with_name_and_account() {
  _not_implemented
}

assert_fail_add_item_with_name() { assert_fail_add_item_with_name_and_account "$1" "" "$2"; }
assert_fail_add_item_with_account() { _not_implemented; }
assert_fail_add_item_with_name_and_account() {
  run _pp_add_item_with_name_and_account "$@"
  assert_failure
  assert_output "Could not create entry with path $1."
}

assert_item_with_name() {
  local item_name="$1" item_pw="$2"
  run _pp_assert_item_with_name "${item_name}"
  assert_success
  assert_output "${item_pw}"
}
_pp_assert_item_with_name() {
  "${PW_KEEPASSXC}" show -qsa Password "${TEST_KEYCHAIN}" "$1" <<< "${TEST_PASSWORD}"
}

assert_item_with_account() {
  _not_implemented
}

assert_item_with_name_and_account() {
  _not_implemented
}

assert_no_item_with_name() {
  local item_name="$1"
  run _pp_assert_no_item_with_name "${item_name}"
  assert_failure
  assert_output "Could not find entry with path ${item_name}."
}
_pp_assert_no_item_with_name() {
  "${PW_KEEPASSXC}" show -qsa Password "${TEST_KEYCHAIN}" "$1" <<< "${TEST_PASSWORD}"
}

assert_no_item_with_account() {
  _not_implemented
}

assert_no_item_with_name_and_account() {
  _not_implemented
}

assert_deleted_item_with_name() {
  local item_name="$1"
  run _pp_assert_deleted_item_with_name "${item_name}"
  assert_success
}
_pp_assert_deleted_item_with_name() {
  "${PW_KEEPASSXC}" show -qsa Password "${TEST_KEYCHAIN}" "/Recycle Bin/$1" <<< "${TEST_PASSWORD}"
}
