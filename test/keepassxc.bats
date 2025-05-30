# shellcheck disable=SC2030,SC2031
setup() {
  load 'keepassxc'
  _setup
  _set_config_with_copy_paste
  # shellcheck disable=SC2016
  _config_append_with_plugin '$PW_HOME/plugins/keepassxc'
  pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

teardown() {
  _delete_keychain
}

################################################################################
# helpers
################################################################################

# shellcheck disable=SC2034
_init_with_key_file() {
  local keyfile="${BATS_TEST_TMPDIR}/pw keepassxc test_keyfile"
  echo "pw keepassxc test_keyfile" > "${keyfile}"
  PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw keepassxc test_with_keyfile.kdbx:keyfile=${keyfile}"
  pw init "${PW_KEYCHAIN}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

_set_keychain() {
  if [[ "$1" == *:* ]]; then
    PW_KEYCHAIN="${1%%:*}"
    PW_KEYCHAIN_OPTIONS="${1#*:}"
  else
    PW_KEYCHAIN="$1"
  fi
}

################################################################################
# assertions
################################################################################

assert_item_not_exists_output() {
  cat << EOF | assert_output -
Could not find entry with path $1.
keepassxc-cli: Error while running the command '${2:-show}'
EOF
}

assert_item_already_exists_output() {
  cat << EOF | assert_output -
Could not create entry with path $1.
keepassxc-cli: Error while running the command 'add'
EOF
}

assert_removes_item_output() {
  refute_output
}

assert_rm_not_found_output() {
  cat << EOF | assert_output -
Entry $1 not found.
keepassxc-cli: Error while running the command 'rm'
EOF
}

assert_username() {
  run keepassxc-cli show -qsa username "${PW_KEYCHAIN}" "$1" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_url() {
  run keepassxc-cli show -qsa url "${PW_KEYCHAIN}" "$1" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_notes() {
  run keepassxc-cli show -qsa notes "${PW_KEYCHAIN}" "$1" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_item_recycled() {
  local password="$1"; shift
  run pw -p "/Recycle Bin/$1"
  assert_success
  assert_output "${password}"
}

################################################################################
# keychain password
################################################################################

@test "reads keychain password from stdin" {
  run "${PROJECT_ROOT}/plugins/keepassxc/keychain_password" "" "" "${PW_KEYCHAIN}" <<< "stdin test"
  assert_success
  assert_output "stdin test"
}

# bats test_tags=tag:manual_test
@test "prompts keychain password when no stdin" {
  _skip_manual_test "'test'"
  run "${PROJECT_ROOT}/plugins/keepassxc/keychain_password" "" "" "${PW_KEYCHAIN}"
  assert_success
  cat << EOF | assert_output -
Enter password to unlock ${PW_KEYCHAIN}:
test
EOF
}

################################################################################
# init
################################################################################

@test "init fails when keychain already exists" {
  assert_init_already_exists <<< "${KEYCHAIN_TEST_PASSWORD}"
}

# bats test_tags=tag:manual_test
@test "inits keychain and prompts keychain password" {
  _skip_manual_test "'test' twice"
  PW_KEYCHAIN="${BATS_TEST_TMPDIR}/manual pw keepassxc test.kdbx"
  run pw init "${PW_KEYCHAIN}"
  assert_success
  assert_file_exists "${PW_KEYCHAIN}"
}

################################################################################
# get
################################################################################

@test "doesn't have item" {
  assert_item_not_exists "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "get with key-file" {
  _init_with_key_file
  assert_item_not_exists "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# add
################################################################################

@test "adds item with name" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_username "${NAME_A}"
  assert_url "${NAME_A}"
  assert_notes "${NAME_A}"
}

@test "adds item with name and account" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_username "${NAME_A}" "${ACCOUNT_A}"
}

@test "adds item with name and url" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_url "${NAME_A}" "${URL_A}"
}

@test "adds item with name and notes" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "" "" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_notes "${NAME_A}" "${MULTI_LINE_NOTES}"
}

@test "adds item in subfolder" {
  assert_adds_item_with_keychain_password "${PW_1}" "group/${NAME_A}"
  assert_item_exists "${PW_1}" "group/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "adds item in subfolder multiple levels deep" {
  assert_adds_item_with_keychain_password "${PW_1}" "group1/group2/group3/${NAME_A}"
  assert_item_exists "${PW_1}" "group1/group2/group3/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "adds item with key-file" {
  _init_with_key_file
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

# bats test_tags=tag:manual_test
@test "prompts keychain password" {
  _skip_manual_test "'${KEYCHAIN_TEST_PASSWORD}'"
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"

  run pw ls
  assert_success
  cat << EOF | assert_output -
Enter password to unlock ${PW_KEYCHAIN}:
${NAME_A}
EOF
}

################################################################################
# add another
################################################################################

@test "adds item with different name" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_adds_item_with_keychain_password "${PW_2}" "${NAME_B}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_item_exists "${PW_2}" "${NAME_B}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# add duplicate
################################################################################

@test "fails when adding item with existing name" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_item_already_exists_with_keychain_password "${PW_2}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# show
################################################################################

@test "shows no item details" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  run pw -p show "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  assert_line --index 0 "Title: ${NAME_A}"
  assert_line --index 1 "UserName: "
  assert_line --index 2 "Password: PROTECTED"
  assert_line --index 3 "URL: "
  assert_line --index 4 "Notes: "
}

@test "shows item details" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  run pw -p show "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output --partial -
Title: ${NAME_A}
UserName: ${ACCOUNT_A}
Password: PROTECTED
URL: ${URL_A}
Notes: ${MULTI_LINE_NOTES}
EOF
}

@test "shows item details in group" {
  assert_adds_item_with_keychain_password "${PW_1}" "group/${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  run pw -p show "group/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output --partial -
Title: ${NAME_A}
UserName: ${ACCOUNT_A}
Password: PROTECTED
URL: ${URL_A}
Notes: ${MULTI_LINE_NOTES}
EOF
}

################################################################################
# rm
################################################################################

@test "removes item" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_adds_item_with_keychain_password "${PW_2}" "${NAME_B}"
  assert_removes_item "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_item_recycled "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_item_exists "${PW_2}" "${NAME_B}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "removes item in subfolder multiple levels deep" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_adds_item_with_keychain_password "${PW_2}" "group1/${NAME_A}"
  assert_adds_item_with_keychain_password "${PW_3}" "group1/group2/${NAME_A}"

  assert_removes_item "group1/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_item_recycled "${PW_2}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"

  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_item_exists "${PW_3}" "group1/group2/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "removes item with key-file" {
  _init_with_key_file
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_removes_item "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# rm non existing item
################################################################################

@test "fails when deleting non existing item" {
  assert_rm_not_found "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# edit
################################################################################

@test "edits item" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_edits_item_with_keychain_password "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "edits item and keeps account, url and notes" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  assert_edits_item_with_keychain_password "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_username "${NAME_A}" "${ACCOUNT_A}"
  assert_url "${NAME_A}" "${URL_A}"
  assert_notes "${NAME_A}" "${MULTI_LINE_NOTES}"
}

@test "edits item with key-file" {
  _init_with_key_file
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}"
  assert_edits_item_with_keychain_password "${PW_2}" "${NAME_A}"
}

################################################################################
# edit non existing item
################################################################################

@test "fails when editing non existing item" {
  run pw edit "${NAME_A}" << EOF
${KEYCHAIN_TEST_PASSWORD}
${PW_2}
EOF
  assert_failure
  assert_item_not_exists_output "${NAME_A}" "edit"
  assert_item_not_exists "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# list item
################################################################################

@test "lists no items" {
  run pw ls <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  refute_output
}

@test "lists sorted items" {
  assert_adds_item_with_keychain_password "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output -
${NAME_A}
${NAME_B}
EOF
}

@test "filters Recycle Bin/" {
  assert_adds_item_with_keychain_password "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw rm "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  run pw ls <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output -
${NAME_B}
EOF
}

@test "lists no items after filtering" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw rm "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  run pw ls <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  refute_output
}

@test "lists no items when wrong keychain password" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls <<< "wrong"
  assert_failure
  cat << EOF | assert_output -
keepassxc-cli: Error while running the command 'ls'
Error while reading the database ${PW_KEYCHAIN}: Invalid credentials were provided, please try again.
EOF
}

@test "lists sorted items with key-file" {
  _init_with_key_file
  assert_adds_item_with_keychain_password "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output -
${NAME_A}
${NAME_B}
EOF
}

@test "lists sorted items with fzf format" {
  assert_adds_item_with_keychain_password "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls fzf <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output -
${NAME_A}			${NAME_A}
${NAME_B}			${NAME_B}
EOF
}

################################################################################
# lock
################################################################################

@test "lock not implemented" {
  run pw lock
  assert_success
  assert_output "not available for keepassxc"
}

################################################################################
# fzf preview
################################################################################

@test "shows fzf preview" {
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"

  local cmd
  cmd="$("${PROJECT_ROOT}/plugins/keepassxc/fzf_preview" "" "${KEYCHAIN_TEST_PASSWORD}" "${PW_KEYCHAIN}")"
  cmd=${cmd//\{4\}/"\"${NAME_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output --partial -
Title: ${NAME_A}
UserName: ${ACCOUNT_A}
Password: PROTECTED
URL: ${URL_A}
Notes: ${MULTI_LINE_NOTES}
EOF
}

@test "shows fzf preview with key-file" {
  _init_with_key_file
  assert_adds_item_with_keychain_password "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"

  _set_keychain "${PW_KEYCHAIN}"
  local cmd
  cmd="$("${PROJECT_ROOT}/plugins/keepassxc/fzf_preview" "${PW_KEYCHAIN_OPTIONS}" "${KEYCHAIN_TEST_PASSWORD}" "${PW_KEYCHAIN}")"
  cmd=${cmd//\{4\}/"\"${NAME_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output --partial -
Title: ${NAME_A}
UserName: ${ACCOUNT_A}
Password: PROTECTED
URL: ${URL_A}
Notes: ${MULTI_LINE_NOTES}
EOF
}

# bats test_tags=tag:manual_test
@test "yanks item to clipboard" {
  _skip_manual_test "yank 'NAME A' to clipboard"
  read -rsp "Press enter to continue ..."
  # fzf strips leading and trailing whitespace, so don't use variables here
  assert_adds_item_with_keychain_password "${PW_1}" "NAME A" "ACCOUNT A" "URL A" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "NAME A" <<< "${KEYCHAIN_TEST_PASSWORD}"

  export PW_CLIP_TIME=1
  bats_require_minimum_version 1.5.0
  run -130 pw <<< "${KEYCHAIN_TEST_PASSWORD}"

  run _paste
  assert_success
  cat << EOF | assert_output --partial -
Title: NAME A
UserName: ACCOUNT A
Password: PROTECTED
URL: URL A
Notes: ${MULTI_LINE_NOTES}
EOF
}

################################################################################
# discover
################################################################################

@test "discovers no keychains" {
  run "${PROJECT_ROOT}/plugins/keepassxc/hook" "discover_keychains"
  assert_success
  refute_output
}

@test "discovers keychains" {
  cd "${BATS_TEST_TMPDIR}"
  run "${PROJECT_ROOT}/plugins/keepassxc/hook" "discover_keychains"
  assert_success
  assert_output "${PW_KEYCHAIN}"
}
