# shellcheck disable=SC2030,SC2031
setup() {
  load 'keepassxc'
  _setup
  export PW_KEEPASSXC_PASSWORD="${KEYCHAIN_TEST_PASSWORD}"
  pw init "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

# shellcheck disable=SC2034
_init_with_key_file() {
  local keyfile="${BATS_TEST_TMPDIR}/pw_keepassxc test_keyfile"
  echo "pw_keepassxc test_keyfile" > "${keyfile}"
  PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw_keepassxc test_with_keyfile.kdbx:keyfile=${keyfile}"
  pw init "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

_set_keychain() {
  declare -Ag PW_KEYCHAIN_ARGS=()
  if [[ "$1" == *:* ]]; then
    PW_KEYCHAIN="${1%%:*}"
    local IFS=,
    for pair in ${1#*:}; do
      PW_KEYCHAIN_ARGS["${pair%%=*}"]="${pair#*=}"
    done
  else
    PW_KEYCHAIN="$1"
  fi
}

teardown() {
  _delete_keychain
}

assert_item_not_exists_output() {
  assert_output "Could not find entry with path $1."
}

assert_item_already_exists_output() {
  assert_output "Could not create entry with path $1."
}

assert_removes_item_output() {
  refute_output
}

assert_rm_not_found_output() {
  assert_output "Entry $1 not found."
}

assert_username() {
  run keepassxc-cli show -qsa username "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_url() {
  run keepassxc-cli show -qsa url "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_notes() {
  run keepassxc-cli show -qsa notes "${PW_KEYCHAIN}" "$1" <<< "${PW_KEEPASSXC_PASSWORD}"
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
# init
################################################################################

@test "init fails when keychain already exists" {
  assert_init_fails <<< "${PW_KEEPASSXC_PASSWORD}"
}

# bats test_tags=tag:manual_test
@test "inits keychain and prompts keychain password" {
  _skip_manual_test "'test' twice"
  PW_KEYCHAIN="${BATS_TEST_TMPDIR}/manual pw_keepassxc test.kdbx"
  run pw init "${PW_KEYCHAIN}"
  assert_success
  assert_file_exists "${PW_KEYCHAIN}"
}

################################################################################
# get
################################################################################

@test "reads keychain password from stdin" {
  unset PW_KEEPASSXC_PASSWORD
  assert_item_not_exists "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
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

@test "adds item with name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_username "${NAME_A}"
  assert_url "${NAME_A}"
  assert_notes "${NAME_A}"
}

@test "adds item with name and account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_username "${NAME_A}" "${ACCOUNT_A}"
}

@test "adds item with name and url" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_url "${NAME_A}" "${URL_A}"
}

@test "adds item with name and notes" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "" "${MULTILINE_NOTES_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_notes "${NAME_A}" "${MULTILINE_NOTES_A}"
}

@test "adds item in subfolder" {
  assert_adds_item "${PW_1}" "group/${NAME_A}"
  assert_item_exists "${PW_1}" "group/${NAME_A}"
}

@test "adds item in subfolder multiple levels deep" {
  assert_adds_item "${PW_1}" "group1/group2/group3/${NAME_A}"
  assert_item_exists "${PW_1}" "group1/group2/group3/${NAME_A}"
}

@test "adds item with key-file" {
  _init_with_key_file
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
}

# bats test_tags=tag:manual_test
@test "prompts keychain password" {
  _skip_manual_test "'${KEYCHAIN_TEST_PASSWORD}'"
  assert_adds_item "${PW_1}" "${NAME_A}"

  unset PW_KEEPASSXC_PASSWORD
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
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"
}

################################################################################
# add duplicate
################################################################################

@test "fails when adding item with existing name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_already_exists "${PW_2}" "${NAME_A}"
}

################################################################################
# show
################################################################################

@test "shows no item details" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw -p show "${NAME_A}"
  assert_success
  assert_line --index 0 "Title: ${NAME_A}"
  assert_line --index 1 "UserName: "
  assert_line --index 2 "Password: PROTECTED"
  assert_line --index 3 "URL: "
  assert_line --index 4 "Notes: "
}

@test "shows item details" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTILINE_NOTES_A}"
  run pw -p show "${NAME_A}"
  assert_success
  cat << EOF | assert_output --partial -
Title: ${NAME_A}
UserName: ${ACCOUNT_A}
Password: PROTECTED
URL: ${URL_A}
Notes: ${MULTILINE_NOTES_A}
EOF
}

################################################################################
# rm
################################################################################

@test "removes item" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_removes_item "${NAME_A}"
  assert_item_recycled "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"
}

@test "removes item item in subfolder multiple levels deep" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "group1/${NAME_A}"
  assert_adds_item "${PW_3}" "group1/group2/${NAME_A}"

  assert_removes_item "group1/${NAME_A}"
  assert_item_recycled "${PW_2}" "${NAME_A}"

  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_3}" "group1/group2/${NAME_A}"
}

@test "removes item with key-file" {
  _init_with_key_file
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_removes_item "${NAME_A}"
}

################################################################################
# rm non existing item
################################################################################

@test "fails when deleting non existing item" {
  assert_rm_not_found "${NAME_A}"
}

################################################################################
# edit
################################################################################

@test "edits item" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_edits_item "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}"
}

@test "edits item and keeps account, url and notes" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTILINE_NOTES_A}"
  assert_edits_item "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}"
  assert_username "${NAME_A}" "${ACCOUNT_A}"
  assert_url "${NAME_A}" "${URL_A}"
  assert_notes "${NAME_A}" "${MULTILINE_NOTES_A}"
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
  assert_item_not_exists_output "${NAME_A}"
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

@test "lists no items when wrong keychain password" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  # shellcheck disable=SC2030
  PW_KEEPASSXC_PASSWORD="wrong"
  run pw ls
  assert_failure
  assert_output "Error while reading the database ${PW_KEYCHAIN}: Invalid credentials were provided, please try again."
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

@test "lists sorted items with fzf format" {
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_A}"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  run pw ls fzf
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
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTILINE_NOTES_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  source "${PROJECT_ROOT}/src/plugins/keepassxc/plugin.bash"
  local cmd
  cmd="$(pw::plugin_fzf_preview)"
  cmd=${cmd//\{4\}/"\"${NAME_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output --partial -
Title: ${NAME_A}
UserName: ${ACCOUNT_A}
Password: PROTECTED
URL: ${URL_A}
Notes: ${MULTILINE_NOTES_A}
EOF
}

@test "shows fzf preview with key-file" {
  _init_with_key_file
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTILINE_NOTES_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  _set_keychain "${PW_KEYCHAIN}"
  source "${PROJECT_ROOT}/src/plugins/keepassxc/plugin.bash"
  local cmd
  cmd="$(pw::plugin_fzf_preview)"
  cmd=${cmd//\{4\}/"\"${NAME_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output --partial -
Title: ${NAME_A}
UserName: ${ACCOUNT_A}
Password: PROTECTED
URL: ${URL_A}
Notes: ${MULTILINE_NOTES_A}
EOF
}

################################################################################
# discover
################################################################################

@test "discovers no keychains" {
  source "${PROJECT_ROOT}/src/plugins/keepassxc/hook.bash"
  run pw::discover_keychains
  assert_success
  refute_output
}

@test "discovers keychains" {
  source "${PROJECT_ROOT}/src/plugins/keepassxc/hook.bash"
  cd "${BATS_TEST_TMPDIR}"
  run pw::discover_keychains
  assert_success
  assert_output "${PW_KEYCHAIN}"
}
