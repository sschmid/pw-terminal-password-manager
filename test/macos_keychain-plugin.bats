setup() {
  load 'pw-test-helper.bash'
  load 'macos_keychain.bash'
  _set_pwrc_with_keychains "${TEST_KEYCHAIN}"
  pw init "${TEST_KEYCHAIN}" <<< " pw test password "
  nameA=" a test name "
  nameB=" b test name "
  accountA=" a test account "
  accountB=" b test account "
  pw1=" 1 test pw "
  pw2=" 2 test pw "
  pw3=" 3 test pw "
}

teardown() { _teardown; }

_pw_with_password() {
  local password="$1"
  shift
  pw "$@" <<< "${password}"
}

################################################################################
# no item
################################################################################

assert_no_item_with_name()             { run pw "$1";      _assert_no_item; run pw -p "$1";      _assert_no_item; }
assert_no_item_with_account()          { run pw "" "$1";   _assert_no_item; run pw -p "" "$1";   _assert_no_item; }
assert_no_item_with_name_and_account() { run pw "$1" "$2"; _assert_no_item; run pw -p "$1" "$2"; _assert_no_item; }

@test "doesn't have item with name" {
  assert_no_item_with_name "${nameA}"
}

@test "doesn't have item with account" {
  assert_no_item_with_account "${accountA}"
}

@test "doesn't have item with name and account" {
  assert_no_item_with_name_and_account "${nameA}" "${accountA}"
}

################################################################################
# add item
################################################################################

add_item_with_name()             { run _pw_with_password "$2" add "$1";      assert_success; }
add_item_with_account()          { run _pw_with_password "$2" add "" "$1";   assert_success; }
add_item_with_name_and_account() { run _pw_with_password "$3" add "$1" "$2"; assert_success; }

_assert_item() {
  assert_success
  assert_output "$1"
}

assert_item_with_name()             { run pw "$1";      assert_success; refute_output; run pbpaste; _assert_item "$2"; run pw -p "$1";      _assert_item "$2"; }
assert_item_with_account()          { run pw "" "$1";   assert_success; refute_output; run pbpaste; _assert_item "$2"; run pw -p "" "$1";   _assert_item "$2"; }
assert_item_with_name_and_account() { run pw "$1" "$2"; assert_success; refute_output; run pbpaste; _assert_item "$3"; run pw -p "$1" "$2"; _assert_item "$3"; }

@test "adds item with name" {
  add_item_with_name "${nameA}" "${pw1}"
  assert_item_with_name "${nameA}" "${pw1}"
}

@test "adds item with account" {
  add_item_with_account "${accountA}" "${pw1}"
  assert_item_with_account "${accountA}" "${pw1}"
}

@test "adds item with name and account" {
  add_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  assert_item_with_name "${nameA}" "${pw1}"
  assert_item_with_account "${accountA}" "${pw1}"
  assert_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
}

################################################################################
# add another item
################################################################################

@test "adds item with different name" {
  add_item_with_name "${nameA}" "${pw1}"
  add_item_with_name "${nameB}" "${pw2}"
  assert_item_with_name "${nameA}" "${pw1}"
  assert_item_with_name "${nameB}" "${pw2}"
}

@test "adds item with different account" {
  add_item_with_account "${accountA}" "${pw1}"
  add_item_with_account "${accountB}" "${pw2}"
  assert_item_with_account "${accountA}" "${pw1}"
  assert_item_with_account "${accountB}" "${pw2}"
}

@test "adds item with different name and existing account" {
  add_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  add_item_with_name_and_account "${nameB}" "${accountA}" "${pw2}"

  assert_item_with_name "${nameA}" "${pw1}"
  assert_item_with_name "${nameB}" "${pw2}"

  assert_item_with_account "${accountA}" "${pw1}"

  assert_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  assert_item_with_name_and_account "${nameB}" "${accountA}" "${pw2}"
}

@test "adds item with existing name and different account" {
  add_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  add_item_with_name_and_account "${nameA}" "${accountB}" "${pw2}"

  assert_item_with_name "${nameA}" "${pw1}"

  assert_item_with_account "${accountA}" "${pw1}"
  assert_item_with_account "${accountB}" "${pw2}"

  assert_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  assert_item_with_name_and_account "${nameA}" "${accountB}" "${pw2}"
}

################################################################################
# add duplicate
################################################################################

assert_fail_add_item_with_name()             { run _pw_with_password "$2" add "$1";      _assert_fail_add_item; }
assert_fail_add_item_with_account()          { run _pw_with_password "$2" add "" "$1";   _assert_fail_add_item; }
assert_fail_add_item_with_name_and_account() { run _pw_with_password "$2" add "$1" "$2"; _assert_fail_add_item; }

@test "fails when adding item with existing name" {
  add_item_with_name "${nameA}" "${pw1}"
  assert_fail_add_item_with_name "${nameA}" "${pw2}"
}

@test "fails when adding item with existing account" {
  add_item_with_account "${accountA}" "${pw1}"
  assert_fail_add_item_with_account "${accountA}" "${pw2}"
}

@test "fails when adding item with existing name and account" {
  add_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  assert_fail_add_item_with_name_and_account "${nameA}" "${accountA}" "${pw2}"
}

################################################################################
# delete item
################################################################################

delete_item_with_name()             { run pw rm "$1";      assert_success; }
delete_item_with_account()          { run pw rm "" "$1";   assert_success; }
delete_item_with_name_and_account() { run pw rm "$1" "$2"; assert_success; }

@test "deletes item with name" {
  add_item_with_name "${nameA}" "${pw1}"
  add_item_with_name "${nameB}" "${pw2}"
  delete_item_with_name "${nameA}"
  assert_no_item_with_name "${nameA}"
  assert_item_with_name "${nameB}" "${pw2}"
}

@test "deletes item with account" {
  add_item_with_account "${accountA}" "${pw1}"
  add_item_with_account "${accountB}" "${pw2}"
  delete_item_with_account "${accountA}"
  assert_no_item_with_account "${accountA}"
  assert_item_with_account "${accountB}" "${pw2}"
}

@test "deletes item with name and account" {
  add_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  add_item_with_name_and_account "${nameB}" "${accountA}" "${pw2}"
  add_item_with_name_and_account "${nameA}" "${accountB}" "${pw3}"
  delete_item_with_name_and_account "${nameA}" "${accountA}"
  assert_no_item_with_name_and_account "${accountA}" "${accountA}"
  assert_item_with_name_and_account "${nameB}" "${accountA}" "${pw2}"
  assert_item_with_name_and_account "${nameA}" "${accountB}" "${pw3}"
}

################################################################################
# delete non existing item
################################################################################

assert_fail_delete_item_with_name()             { run pw rm "$1";      _assert_no_item; }
assert_fail_delete_item_with_account()          { run pw rm "" "$1";   _assert_no_item; }
assert_fail_delete_item_with_name_and_account() { run pw rm "$1" "$2"; _assert_no_item; }

@test "fails when deleting non existing item with name" {
  assert_fail_delete_item_with_name "${nameA}"
}

@test "fails when deleting non existing item with account" {
  assert_fail_delete_item_with_account "${accountA}"
}

@test "fails when deleting non existing item with name and account" {
  assert_fail_delete_item_with_name_and_account "${nameA}" "${accountA}"
}

################################################################################
# update item
################################################################################

update_item_with_name()             { run _pw_with_password "$2" edit "$1";      assert_success; }
update_item_with_account()          { run _pw_with_password "$2" edit "" "$1";   assert_success; }
update_item_with_name_and_account() { run _pw_with_password "$3" edit "$1" "$2"; assert_success; }

@test "updates item with existing name" {
  add_item_with_name "${nameA}" "${pw1}"
  update_item_with_name "${nameA}" "${pw2}"
  assert_item_with_name "${nameA}" "${pw2}"
}

@test "updates item with existing account" {
  add_item_with_account "${accountA}" "${pw1}"
  update_item_with_account "${accountA}" "${pw2}"
  assert_item_with_account "${accountA}" "${pw2}"
}

@test "updates item with existing name and account" {
  add_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  update_item_with_name_and_account "${nameA}" "${accountA}" "${pw2}"
  assert_item_with_name_and_account "${nameA}" "${accountA}" "${pw2}"
}

################################################################################
# update non existing item
################################################################################

@test "adds item when updating non existing item with name" {
  update_item_with_name "${nameA}" "${pw2}"
  assert_item_with_name "${nameA}" "${pw2}"
}

@test "adds item when updating non existing item with account" {
  update_item_with_account "${accountA}" "${pw2}"
  assert_item_with_account "${accountA}" "${pw2}"
}

@test "adds item when updating non existing item with name and account" {
  update_item_with_name_and_account "${nameA}" "${accountA}" "${pw2}"
  assert_item_with_name_and_account "${nameA}" "${accountA}" "${pw2}"
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
  add_item_with_name_and_account "${nameB}" "${accountB}" "${pw2}"
  add_item_with_name_and_account "${nameA}" "${accountA}" "${pw1}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
${nameA}                           	${accountA}
${nameB}                           	${accountB}
EOF
}

@test "lists handles <NULL> name" {
  add_item_with_account "${accountA}" "${pw1}"
  run pw ls
  assert_success
  assert_output "                                        	${accountA}"
}

@test "lists handles <NULL> account" {
  add_item_with_name "${nameA}" "${pw1}"
  run pw ls
  assert_success
  assert_output "${nameA}                           	"
}

################################################################################
# clipboard
################################################################################

@test "clears clipboard after copying item" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  add_item_with_name "${nameA}" "${pw1}"
  run pw "${nameA}"
  sleep 2
  run pbpaste
  refute_output
}

@test "doesn't clear clipboard when changed" {
  # shellcheck disable=SC2030,SC2031
  export PW_CLIP_TIME=1
  add_item_with_name "${nameA}" "${pw1}"
  run pw "${nameA}"
  echo -n "changed" | pbcopy
  sleep 2
  run pbpaste
  assert_output "changed"
}
