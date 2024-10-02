# shellcheck disable=SC2030,SC2031
setup_file() {
  export GNUPGHOME="${BATS_FILE_TMPDIR}/.gnupg"
  gpg --batch --pinentry-mode loopback --passphrase pw_test_password \
      --import "${BATS_TEST_DIRNAME}/fixtures/pw_test_1.key"
  gpg --batch --pinentry-mode loopback --passphrase pw_test_password \
      --import "${BATS_TEST_DIRNAME}/fixtures/pw_test_2.key"
}

teardown_file() {
  killall gpg-agent 2> /dev/null || true
}

setup() {
  load 'gpg'
  _setup
  export PW_GPG_PASSWORD="pw_test_password"
  pw init "${PW_KEYCHAIN}"
}

teardown() {
  _delete_keychain
}

# shellcheck disable=SC2009
_ps() { ps -A | grep "gpg-agent" | grep -v grep; }

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
  assert_output "rm: ${PW_KEYCHAIN}/$1: No such file or directory"
}

_gpg_decrypt() {
  gpg --quiet --batch --pinentry-mode loopback --passphrase "${PW_GPG_PASSWORD}" \
      --decrypt "${PW_KEYCHAIN}/$1" | sed -n "$2"
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

################################################################################
# init
################################################################################

@test "init fails when keychain already exists" {
  assert_init_fails
}

################################################################################
# get
################################################################################

@test "doesn't have item" {
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

@test "adds item with .gpg extension" {
  assert_adds_item "${PW_1}" "${NAME_A}.gpg"
  assert_item_exists "${PW_1}" "${NAME_A}.gpg"
  run file -b "${PW_KEYCHAIN}/${NAME_A}.gpg"
  assert_output "data"
}

@test "adds item with .asc extension" {
  assert_adds_item "${PW_1}" "${NAME_A}.asc"
  assert_item_exists "${PW_1}" "${NAME_A}.asc"
  run file -b "${PW_KEYCHAIN}/${NAME_A}.asc"
  assert_output --partial "PGP message Public-Key Encrypted Session Key"
}

@test "adds item with key id" {
  local keychain="${PW_KEYCHAIN}"
  local key_id="634419040D678764"
  PW_KEYCHAIN="${keychain}:key=${key_id}"
  assert_adds_item "${PW_1}" "${NAME_A}"
  run gpg --batch --pinentry-mode loopback --passphrase "${PW_GPG_PASSWORD}" \
          --list-packets "${keychain}/${NAME_A}"
  assert_success
  assert_output --partial "keyid ${key_id}"
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
# rm
################################################################################

@test "removes item" {
  assert_adds_item "${PW_1}" "${NAME_A}"
  assert_adds_item "${PW_2}" "${NAME_B}"
  assert_removes_item "${NAME_A}"
  assert_item_not_exists "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_B}"
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

# shellcheck disable=SC2034
@test "edits item with key id" {
  local keychain="${PW_KEYCHAIN}"
  PW_KEYCHAIN="${keychain}:key=634419040D678764"
  assert_adds_item "${PW_1}" "${NAME_A}"

  local key_id="8593E03F5A33D9AC"
  PW_KEYCHAIN="${keychain}:key=${key_id}"
  assert_edits_item "${PW_2}" "${NAME_A}"
  run gpg --batch --pinentry-mode loopback --passphrase "${PW_GPG_PASSWORD}" \
          --list-packets "${keychain}/${NAME_A}"
  assert_success
  assert_output --partial "keyid ${key_id}"
}

################################################################################
# edit non existing item
################################################################################

@test "fails when editing non existing item" {
  run pw edit "${NAME_A}" <<< "${PW_2}"
  assert_failure
  assert_item_not_exists_output "${NAME_A}"
  assert_item_not_exists "${NAME_A}"
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
  run pw open
  assert_success
  refute_output
}

################################################################################
# lock
################################################################################

@test "unlocks keychain" {
  run _ps
  assert_success
  assert_output --partial "gpg-agent --homedir ${GNUPGHOME}"

  run pw lock
  assert_success
  refute_output

  run _ps
  assert_failure
  refute_output

  run pw unlock <<< "${PW_GPG_PASSWORD}"
  assert_success
  refute_output

  run _ps
  assert_success
  assert_output --partial "gpg-agent --homedir ${GNUPGHOME}"
}

# bats test_tags=tag:manual_test
@test "unlocks keychain and prompts keychain password" {
  unset PW_GPG_PASSWORD
  _skip_manual_test "pw_test_password - Press enter to continue ..."
  read -rsp "Press enter to continue ..."

  run _ps
  assert_success
  assert_output --partial "gpg-agent --homedir ${GNUPGHOME}"

  run pw lock
  assert_success
  refute_output

  run _ps
  assert_failure
  refute_output

  run pw unlock
  assert_success
  refute_output

  run _ps
  assert_success
  assert_output --partial "gpg-agent --homedir ${GNUPGHOME}"
}

################################################################################
# fzf preview
################################################################################

@test "shows fzf preview" {
  assert_adds_item "${PW_1}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTILINE_NOTES_A}"
  assert_item_exists "${PW_1}" "${NAME_A}"

  source "${PROJECT_ROOT}/src/plugins/gpg/plugin.bash"
  local cmd
  cmd="$(pw::plugin_fzf_preview)"
  cmd=${cmd/\{4\}/"\"${NAME_A}\""}

  run eval "${cmd}"
  assert_success
  cat << EOF | assert_output -
Account: ${ACCOUNT_A}
URL: ${URL_A}
Notes:
${MULTILINE_NOTES_A}
EOF
}

################################################################################
# discover
################################################################################

@test "discovers no keychains" {
  source "${PROJECT_ROOT}/src/plugins/gpg/hook.bash"
  run pw::discover_keychains
  assert_success
  refute_output
}

@test "discovers .gpg" {
  assert_adds_item "${PW_1}" "${NAME_A}.gpg"
  assert_item_exists "${PW_1}" "${NAME_A}.gpg"

  source "${PROJECT_ROOT}/src/plugins/gpg/hook.bash"
  cd "${PW_KEYCHAIN}"
  run pw::discover_keychains
  assert_success
  assert_output "${PW_KEYCHAIN}"
}

@test "discovers .asc" {
  assert_adds_item "${PW_1}" "${NAME_A}.asc"
  assert_item_exists "${PW_1}" "${NAME_A}.asc"

  source "${PROJECT_ROOT}/src/plugins/gpg/hook.bash"
  cd "${PW_KEYCHAIN}"
  run pw::discover_keychains
  assert_success
  assert_output "${PW_KEYCHAIN}"
}
