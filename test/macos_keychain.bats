# shellcheck disable=SC2030,SC2031
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
  assert_init_fails <<< "${KEYCHAIN_TEST_PASSWORD}"
}

# bats test_tags=tag:manual_test
@test "inits keychain and prompts keychain password" {
  _skip_manual_test "'test' twice"
  PW_KEYCHAIN="${BATS_TEST_TMPDIR}/manual pw_macos_keychain test.keychain-db"
  run pw init "${PW_KEYCHAIN}"
  assert_success
  assert_file_exists "${PW_KEYCHAIN}"
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

@test "adds item with name and url" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}" "" "${URL_B}"

  assert_item_exists "${PW_2}" "${NAME_B}"
  assert_item_exists "${PW_2}" "" "" "${URL_B}"

  assert_item_exists "${PW_2}" "${NAME_B}" "" "${URL_B}"
}

@test "label swizzling: name-only is label and service" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  run security find-generic-password -l "${NAME_A}" -w "${PW_KEYCHAIN}"
  assert_success
  assert_output "${PW_1}"

  run security find-generic-password -s "${NAME_A}" -w "${PW_KEYCHAIN}"
  assert_success
  assert_output "${PW_1}"
}

@test "label swizzling: url-only is label and service" {
  assert_adds_item "${PW_1}" "" "" "${URL_A}"
  assert_item_exists "${PW_1}" "" "" "${URL_A}"

  run security find-generic-password -s "${URL_A}" -w "${PW_KEYCHAIN}"
  assert_success
  assert_output "${PW_1}"

  run security find-generic-password -l "${URL_A}" -w "${PW_KEYCHAIN}"
  assert_success
  assert_output "${PW_1}"
}

@test "label swizzling: name and url are label and service" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "" "" "${URL_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" "" "${URL_A}"

  run security find-generic-password -l "${NAME_A}" -w "${PW_KEYCHAIN}"
  assert_success
  assert_output "${PW_1}"

  run security find-generic-password -s "${URL_A}" -w "${PW_KEYCHAIN}"
  assert_success
  assert_output "${PW_1}"
}

@test "adds item with name and single line notes" {
  local notes="single line notes"
  assert_adds_item "${PW_1}" "${NAME_A}" "" "" "${notes}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  # shellcheck disable=SC2317
  _get_note() {
    local comments
    comments="$(security find-generic-password -j "${notes}" -g "${PW_KEYCHAIN}" 2>&1 \
      | awk 'BEGIN { FS="<blob>=" } /"icmt"/ { print ($2 == "<NULL>") ? "" : $2 }')"
    echo "${comments:1:-1}"
  }

  run _get_note
  assert_success
  cat << EOF | assert_output -
${notes}
EOF
}

@test "adds item with name and multiline notes" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "" "${MULTILINE_NOTES_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  _get_note() {
    security find-generic-password -j "${MULTILINE_NOTES_A}" -g "${PW_KEYCHAIN}" 2>&1 \
      | awk 'BEGIN { FS="<blob>=" } /"icmt"/ { print ($2 == "<NULL>") ? "" : $2 }' \
      | xxd -r -p
  }

  run _get_note
  assert_success
  cat << EOF | assert_output -
${MULTILINE_NOTES_A}
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

@test "adds item with different url" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_adds_item "${PW_2}" "${NAME_A}" "" "${URL_B}"
  assert_item_exists "${PW_1}" "" "" "${URL_A}"
  assert_item_exists "${PW_2}" "" "" "${URL_B}"
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

@test "removes item with name and url" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_adds_item "${PW_2}" "${NAME_B}" "" "${URL_B}"
  assert_removes_item "${NAME_A}" "" "${URL_A}"
  assert_item_not_exists "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"
}

@test "removes item with url" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_adds_item "${PW_2}" "${NAME_B}" "" "${URL_B}"
  assert_removes_item "" "" "${URL_A}"
  assert_item_not_exists "" "" "${URL_A}"
  assert_item_exists "${PW_2}" "" "" "${URL_B}"
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

@test "edits item with name and url" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_edits_item "${PW_2}" "${NAME_A}" "" "${URL_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" "" "${URL_A}"
}

@test "edits item with url" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_edits_item "${PW_2}" "" "" "${URL_A}"
  assert_item_exists "${PW_2}" "" "" "${URL_A}"
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
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_B}" "${URL_B}"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
${NAME_A}           	${ACCOUNT_A}        	${URL_A}
${NAME_B}           	${ACCOUNT_B}        	${URL_B}
EOF
}

@test "ls handles <NULL> name" {
  assert_adds_item "${PW_1}" "" "${ACCOUNT_A}"
  run pw ls
  assert_success
  assert_output "                        	${ACCOUNT_A}        	"
}

@test "ls handles <NULL> account" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw ls
  assert_success
  assert_output "${NAME_A}           	                        	${NAME_A}"
}

@test "ls handles = in name" {
  assert_adds_item "${PW_1}" "te=st"
  run pw ls
  assert_success
  assert_output "te=st                   	                        	te=st"
}

@test "lists sorted items with fzf format" {
  assert_adds_item "${PW_2}" "${NAME_B}" "${ACCOUNT_B}" "${URL_B}"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
  run pw ls fzf
  assert_success
  cat << EOF | assert_output -
${NAME_A}           	${ACCOUNT_A}        	${URL_A}	${NAME_A}	${ACCOUNT_A}	${URL_A}
${NAME_B}           	${ACCOUNT_B}        	${URL_B}	${NAME_B}	${ACCOUNT_B}	${URL_B}
EOF
}

################################################################################
# lock
################################################################################

@test "unlocks keychain" {
  run security show-keychain-info "${PW_KEYCHAIN}"
  assert_success
  assert_output "Keychain \"${PW_KEYCHAIN}\" lock-on-sleep timeout=300s"

  run pw lock
  assert_success
  refute_output

  run pw unlock <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  refute_output

  run security show-keychain-info "${PW_KEYCHAIN}"
  assert_success
  assert_output "Keychain \"${PW_KEYCHAIN}\" lock-on-sleep timeout=300s"
}

# bats test_tags=tag:manual_test
@test "unlocks keychain and prompts keychain password" {
  _skip_manual_test "'${KEYCHAIN_TEST_PASSWORD}'"

  run pw lock
  assert_success
  refute_output

  run pw unlock
  assert_success
  refute_output

  run security show-keychain-info "${PW_KEYCHAIN}"
  assert_success
  assert_output "Keychain \"${PW_KEYCHAIN}\" lock-on-sleep timeout=300s"
}

################################################################################
# fzf preview
################################################################################

# bats test_tags=tag:manual_test
@test "doesn't show fzf preview when locked" {
  _skip_manual_test "no password and cancel"

  assert_adds_item "${PW_1}" "${NAME_A}" "" "" "${MULTILINE_NOTES_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  source "${PROJECT_ROOT}/src/plugins/macos_keychain/plugin.bash"
  run pw lock
  run pw::plugin_fzf_preview
  assert_success
  refute_output
}

@test "shows fzf preview for single line notes" {
  local notes="single line notes"
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${notes}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  source "${PROJECT_ROOT}/src/plugins/macos_keychain/plugin.bash"
  local cmd
  cmd="$(pw::plugin_fzf_preview)"
  cmd=${cmd/\{4\}/"\"${NAME_A}\""}
  cmd=${cmd/\{5\}/"\"${ACCOUNT_A}\""}
  cmd=${cmd/\{6\}/"\"${URL_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output -
Name: ${NAME_A}
Account: ${ACCOUNT_A}
Where: ${URL_A}
Comments:
${notes}
EOF
}

@test "shows fzf preview for multiline notes" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTILINE_NOTES_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  source "${PROJECT_ROOT}/src/plugins/macos_keychain/plugin.bash"
  local cmd
  cmd="$(pw::plugin_fzf_preview)"
  cmd=${cmd/\{4\}/"\"${NAME_A}\""}
  cmd=${cmd/\{5\}/"\"${ACCOUNT_A}\""}
  cmd=${cmd/\{6\}/"\"${URL_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output -
Name: ${NAME_A}
Account: ${ACCOUNT_A}
Where: ${URL_A}
Comments:
${MULTILINE_NOTES_A}
EOF
}

################################################################################
# discover
################################################################################

@test "discovers no keychains" {
  source "${PROJECT_ROOT}/src/plugins/macos_keychain/hook.bash"
  run pw::discover_keychains
  assert_success
  refute_output
}

@test "discovers keychains" {
  source "${PROJECT_ROOT}/src/plugins/macos_keychain/hook.bash"
  cd "${BATS_TEST_TMPDIR}"
  run pw::discover_keychains
  assert_success
  assert_output "${PW_KEYCHAIN}"
}
