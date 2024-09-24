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

################################################################################
# init
################################################################################

@test "init fails when keychain already exists" {
  run pw init "${PW_KEYCHAIN}"
  assert_failure
  assert_output "${PW_KEYCHAIN} already exists."
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
}

@test "adds item in subfolder" {
  assert_adds_item "${PW_1}" "group/${NAME_A}"
  assert_item_exists "${PW_1}" "group/${NAME_A}"
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

@test "adds item when editing non existing item" {
  assert_edits_item "${PW_2}" "${NAME_A}"
  assert_item_exists "${PW_2}" "${NAME_A}"
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
./${NAME_A}		./${NAME_A}
./${NAME_B}		./${NAME_B}
EOF
}

################################################################################
# fzf preview
################################################################################

@test "doesn't show fzf preview" {
  source "${PROJECT_ROOT}/src/plugins/gpg/plugin.bash"
  run pw::plugin_fzf_preview
  assert_success
  refute_output
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
