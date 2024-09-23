setup() {
  load 'keepassxc'
  _setup
  export PW_KEEPASSXC_PASSWORD="${KEYCHAIN_TEST_PASSWORD}"
  pw init "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

# shellcheck disable=SC2034
_init_with_key_file() {
  local keyfile="${BATS_TEST_TMPDIR}/pw_keepassxc_test_keyfile.kdbx"
  echo "pw_keepassxc_test_keyfile" > "${keyfile}"
  PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_keepassxc_test_with_keyfile.kdbx:keyfile=${keyfile}"
  pw init "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

teardown() {
  _delete_keychain
}

################################################################################
# init
################################################################################

@test "init fails when keychain already exists" {
  run pw init "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}"
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
  run pw -p "$@"
  assert_failure
  assert_output "Could not find entry with path $1."
}

assert_item_recycled() {
  local password="$1"; shift
  run pw -p "/Recycle Bin/$1"
  assert_success
  assert_output "${password}"
}

@test "doesn't have item" {
  assert_item_not_exists "${NAME_A}"
}

@test "get with key-file" {
  _init_with_key_file
  assert_item_not_exists "${NAME_A}"
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

assert_username() {
  run keepassxc-cli show -qsa username "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
  assert_success
  if (($# == 2))
  then assert_output "$2"
  else refute_output
  fi
}

@test "adds item with name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_username "${NAME_A}"
}

@test "adds item with name and account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_username "${NAME_A}" "${ACCOUNT_A}"
}

@test "adds item with key-file" {
  _init_with_key_file
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
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

################################################################################
# add duplicate
################################################################################

assert_item_already_exists() {
  local password="$1"; shift
  run pw add "$@" <<< "${password}"
  assert_failure
  assert_output "Could not create entry with path $1."
}

@test "fails when adding item with existing name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_already_exists "${PW_2}" "${NAME_A}"
}

################################################################################
# rm
################################################################################

@test "removes item" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  run pw rm "${NAME_A}"
  assert_success
  refute_output
  assert_item_recycled "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"
}

@test "removes item with key-file" {
  _init_with_key_file
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw rm "${NAME_A}"
  assert_success
  refute_output
}

################################################################################
# rm non existing item
################################################################################

@test "fails when deleting non existing item" {
  run pw rm "${NAME_A}"
  assert_failure
  assert_output "Entry ${NAME_A} not found."
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

@test "edits item" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_edits_item "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}"
}

@test "edits item with key-file" {
  _init_with_key_file
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_edits_item "${PW_2}" "${NAME_A}"
}

################################################################################
# edit non existing item
################################################################################

@test "fails when editing non existing item" {
  run pw edit "${NAME_A}" <<< "${PW_2}"
  assert_failure
  assert_output "Could not find entry with path ${NAME_A}."
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
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
${NAME_A}
${NAME_B}
EOF
}

@test "filters Recycle Bin/" {
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw rm "${NAME_A}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
${NAME_B}
EOF
}

@test "lists no items after filtering" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw rm "${NAME_A}"
  run pw ls
  assert_success
  refute_output
}

@test "lists sorted items with key-file" {
  _init_with_key_file
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
${NAME_A}
${NAME_B}
EOF
}
