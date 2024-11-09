# shellcheck disable=SC2030,SC2031
setup_file() {
  export BATS_NO_PARALLELIZE_WITHIN_FILE=true
  export GNUPGHOME="${BATS_FILE_TMPDIR}/.gnupg"
  gpg --batch --pinentry-mode loopback --passphrase pw_test_password \
      --import "${BATS_TEST_DIRNAME}/fixtures/pw_test_1.key"
  gpg --batch --pinentry-mode loopback --passphrase pw_test_password \
      --import "${BATS_TEST_DIRNAME}/fixtures/pw_test_2.key"
  gpgconf --kill gpg-agent
}

setup() {
  load 'gpg'
  _setup
  # shellcheck disable=SC2016
  _set_pwrc_with_plugin '$PW_HOME/plugins/gpg'
  KEYCHAIN_TEST_PASSWORD="pw_test_password"
  pw init "${PW_KEYCHAIN}"
}

teardown() {
  _delete_keychain
  gpgconf --kill gpg-agent
}

################################################################################
# helpers
################################################################################

# shellcheck disable=SC2009
_ps() {
  case "${OSTYPE}" in
    darwin*) ps -A | grep "gpg-agent --homedir ${GNUPGHOME}" | grep -v grep ;;
    linux*) ps -A | grep "gpg-agent" | grep -v grep ;;
    *) echo "Unsupported OS: ${OSTYPE}"; return 1 ;;
  esac
}

_gpg_decrypt() {
  gpg --quiet --batch --pinentry-mode loopback --passphrase "${KEYCHAIN_TEST_PASSWORD}" \
      --decrypt "${PW_KEYCHAIN}/$1" | sed -n "$2"
}

################################################################################
# assertions
################################################################################

assert_item_not_exists_output() {
  cat << EOF | assert_output -
gpg: can't open '${PW_KEYCHAIN}/$1': No such file or directory
gpg: decrypt_message failed: No such file or directory
EOF
}

assert_item_already_exists_output() {
  assert_output "gpg: [stdin]: encryption failed: File exists"
}

assert_removes_item_output() {
  refute_output
}

assert_rm_not_found_output() {
  case "${OSTYPE}" in
    darwin*) assert_output "rm: ${PW_KEYCHAIN}/$1: No such file or directory" ;;
    linux-musl*) assert_output "rm: can't remove '${PW_KEYCHAIN}/$1': No such file or directory" ;;
    linux*) assert_output "rm: cannot remove '${PW_KEYCHAIN}/$1': No such file or directory" ;;
    *) echo "Unsupported OS: ${OSTYPE}"; return 1 ;;
  esac
}

assert_username() {
  run _gpg_decrypt "$1" 2p
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_url() {
  run _gpg_decrypt "$1" 3p
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_notes() {
  # shellcheck disable=SC2016
  run _gpg_decrypt "$1" '4,$p'
  assert_success
  if (( $# == 2 ))
  then assert_output "$2"
  else refute_output
  fi
}

assert_keyid() {
  local keychain_password="$1" path="$2" key_id="$3"
  run gpg --batch --pinentry-mode loopback --passphrase "${keychain_password}" \
          --list-packets "${path}"
  assert_success
  assert_output --partial "keyid ${key_id}"
}

################################################################################
# keychain password
################################################################################

@test "reads keychain password from stdin" {
  run "${PROJECT_ROOT}/plugins/gpg/keychain_password" "" "get" "${PW_KEYCHAIN}" <<< "stdin test"
  assert_success
  assert_output "stdin test"
}

################################################################################
# init
################################################################################

@test "init fails when keychain already exists" {
  assert_init_already_exists
}

################################################################################
# get
################################################################################

@test "doesn't have item" {
  assert_item_not_exists "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# add
################################################################################

@test "adds item with name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_username "${NAME_A}"
  assert_url "${NAME_A}"
  assert_notes "${NAME_A}"
}

@test "adds item with name and account" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_username "${NAME_A}" "${ACCOUNT_A}"
}

@test "adds item with name and url" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "${URL_A}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_url "${NAME_A}" "${URL_A}"
}

@test "adds item with name and notes" {
  assert_adds_item "${PW_1}" "${NAME_A}" "" "" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_notes "${NAME_A}" "${MULTI_LINE_NOTES}"
}

@test "adds item in subfolder" {
  assert_adds_item "${PW_1}" "group/${NAME_A}"
  assert_item_exists "${PW_1}" "group/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "adds item in subfolder multiple levels deep" {
  assert_adds_item "${PW_1}" "group1/group2/group3/${NAME_A}"
  assert_item_exists "${PW_1}" "group1/group2/group3/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "adds item with .gpg extension" {
  assert_adds_item "${PW_1}" "${NAME_A}.gpg"
  assert_item_exists "${PW_1}" "${NAME_A}.gpg" <<< "${KEYCHAIN_TEST_PASSWORD}"
  run file -b "${PW_KEYCHAIN}/${NAME_A}.gpg"
  assert_output "data"
}

@test "adds item with .asc extension" {
  assert_adds_item "${PW_1}" "${NAME_A}.asc"
  assert_item_exists "${PW_1}" "${NAME_A}.asc" <<< "${KEYCHAIN_TEST_PASSWORD}"
  run file -b "${PW_KEYCHAIN}/${NAME_A}.asc"
  assert_output --partial "PGP message Public-Key Encrypted Session Key"
}

@test "adds item with key id" {
  local keychain="${PW_KEYCHAIN}"
  local key_id="8593E03F5A33D9AC"
  PW_KEYCHAIN="${keychain}:key=${key_id}"
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_keyid "${KEYCHAIN_TEST_PASSWORD}" "${keychain}/${NAME_A}" ${key_id}
}

################################################################################
# add another
################################################################################

@test "adds item with different name" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_item_exists "${PW_2}" "${NAME_B}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

################################################################################
# add duplicate
################################################################################

# bats test_tags=tag:manual_test
@test "prompts for new filename when adding item with existing name" {
  _skip_manual_test "new filename: '${PW_KEYCHAIN}/new_name'"
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw add "${NAME_A}" <<< "${PW_2}"
  assert_success
  assert_file_exists "${PW_KEYCHAIN}/new_name"
}

################################################################################
# show
################################################################################

@test "shows no item details" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw -p show "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  assert_line --index 0 "Name: ${NAME_A}"
  assert_line --index 1 "Account: "
  assert_line --index 2 "URL: "
  assert_line --index 3 "Notes:"
}

@test "shows item details" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  run pw -p show "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output -
Name: ${NAME_A}
Account: ${ACCOUNT_A}
URL: ${URL_A}
Notes:
${MULTI_LINE_NOTES}
EOF
}

@test "shows item details in group" {
  assert_adds_item "${PW_1}" "group/${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  run pw -p show "group/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  cat << EOF | assert_output -
Name: ${NAME_A}
Account: ${ACCOUNT_A}
URL: ${URL_A}
Notes:
${MULTI_LINE_NOTES}
EOF
}

################################################################################
# rm
################################################################################

@test "removes item" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_removes_item "${NAME_A}"
  assert_item_not_exists "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_item_exists "${PW_2}" "${NAME_B}" <<< "${KEYCHAIN_TEST_PASSWORD}"
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
  assert_edits_item_with_keychain_password "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
}

@test "edits item and keeps account, url and notes" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  assert_edits_item_with_keychain_password "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_username "${NAME_A}" "${ACCOUNT_A}"
  assert_url "${NAME_A}" "${URL_A}"
  assert_notes "${NAME_A}" "${MULTI_LINE_NOTES}"
}

# shellcheck disable=SC2034
@test "edits item with key id" {
  local keychain="${PW_KEYCHAIN}"
  PW_KEYCHAIN="${keychain}:key=634419040D678764"
  assert_adds_item "${PW_1}" "${NAME_A}"

  local key_id="8593E03F5A33D9AC"
  PW_KEYCHAIN="${keychain}:key=${key_id}"
  assert_edits_item_with_keychain_password "${PW_2}" "${NAME_A}"
  assert_keyid "${KEYCHAIN_TEST_PASSWORD}" "${keychain}/${NAME_A}" ${key_id}
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
  assert_item_not_exists_output "${NAME_A}"
  assert_item_not_exists "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"
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
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
./${NAME_A}
./${NAME_B}
EOF
}

@test "filters .DS_Store" {
  touch "${PW_KEYCHAIN}/.DS_Store"
  run pw ls
  assert_success
  refute_output
}

@test "lists sorted items with fzf format" {
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_adds_item "${PW_1}" "${NAME_A}"
  run pw ls fzf
  assert_success
  cat << EOF | assert_output -
./${NAME_A}			./${NAME_A}
./${NAME_B}			./${NAME_B}
EOF
}

################################################################################
# open
################################################################################

@test "opens keychain" {
  _skip_when_not_macos
  run pw open
  assert_success
  refute_output
}

################################################################################
# lock
################################################################################

@test "unlocks keychain" {
  run _ps
  assert_failure
  refute_output

  run pw unlock <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success
  refute_output

  run _ps
  assert_success
  assert_output
}

# bats test_tags=tag:manual_test
@test "unlocks keychain and prompts keychain password" {
  _skip_manual_test "pw_test_password - Press enter to continue ..."
  read -rsp "Press enter to continue ..."

  run _ps
  assert_failure
  refute_output

  run pw unlock
  assert_success
  refute_output

  run _ps
  assert_success
  assert_output
}

################################################################################
# fzf preview
################################################################################

@test "shows fzf preview" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"

  local cmd
  cmd="$("${PROJECT_ROOT}/plugins/gpg/fzf_preview" "" "" "${PW_KEYCHAIN}")"
  cmd=${cmd//\{4\}/"\"${NAME_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output -
Name: ${NAME_A}
Account: ${ACCOUNT_A}
URL: ${URL_A}
Notes:
${MULTI_LINE_NOTES}
EOF
}

@test "shows fzf preview of item in group" {
  assert_adds_item "${PW_1}" "group/${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "group/${NAME_A}" <<< "${KEYCHAIN_TEST_PASSWORD}"

  local cmd
  cmd="$("${PROJECT_ROOT}/plugins/gpg/fzf_preview" "" "" "${PW_KEYCHAIN}")"
  cmd=${cmd//\{4\}/"\"group/${NAME_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output -
Name: ${NAME_A}
Account: ${ACCOUNT_A}
URL: ${URL_A}
Notes:
${MULTI_LINE_NOTES}
EOF
}

# bats test_tags=tag:manual_test
@test "yanks item to clipboard" {
  _skip_manual_test "yank 'NAME A' to clipboard"
  read -rsp "Press enter to continue ..."
  # fzf strips leading and trailing whitespace, so don't use variables here
  assert_adds_item "${PW_1}" "NAME A" "ACCOUNT A" "URL A" "${MULTI_LINE_NOTES}"
  assert_item_exists "${PW_1}" "NAME A" <<< "${KEYCHAIN_TEST_PASSWORD}"

  run pw unlock <<< "${KEYCHAIN_TEST_PASSWORD}"
  assert_success

  export PW_CLIP_TIME=1
  bats_require_minimum_version 1.5.0
  run -130 pw

  run _paste
  assert_success
  cat << EOF | assert_output -
Name: NAME A
Account: ACCOUNT A
URL: URL A
Notes:
${MULTI_LINE_NOTES}
EOF
}

################################################################################
# discover
################################################################################

@test "discovers no keychains" {
  run "${PROJECT_ROOT}/plugins/gpg/hook" "discover_keychains"
  assert_success
  refute_output
}

@test "discovers .gpg" {
  assert_adds_item "${PW_1}" "${NAME_A}.gpg"
  assert_item_exists "${PW_1}" "${NAME_A}.gpg" <<< "${KEYCHAIN_TEST_PASSWORD}"

  cd "${PW_KEYCHAIN}"
  run "${PROJECT_ROOT}/plugins/gpg/hook" "discover_keychains"
  assert_success
  assert_output "${PW_KEYCHAIN}"
}

@test "discovers .asc" {
  assert_adds_item "${PW_1}" "${NAME_A}.asc"
  assert_item_exists "${PW_1}" "${NAME_A}.asc" <<< "${KEYCHAIN_TEST_PASSWORD}"

  cd "${PW_KEYCHAIN}"
  run "${PROJECT_ROOT}/plugins/gpg/hook" "discover_keychains"
  assert_success
  assert_output "${PW_KEYCHAIN}"
}
