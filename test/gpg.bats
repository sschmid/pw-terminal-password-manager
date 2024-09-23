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

  nameA=" a test name "
  nameB=" b test name "
  pw1=" 1 test pw "
  pw2=" 2 test pw "
}

teardown() {
  _delete_keychain
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

assert_item_exists() {
  local password="$1"; shift
  run pw -p "$@"
  assert_success
  assert_output "${password}"
}

assert_item_not_exists() {
  run pw -p "$@"
  assert_failure
  cat << EOF | assert_output -
gpg: can't open '${PW_KEYCHAIN}/$1': No such file or directory
gpg: decrypt_message failed: No such file or directory
EOF
}

@test "doesn't have item" {
  assert_item_not_exists "${nameA}"
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

@test "adds item with name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_item_exists "${pw1}" "${nameA}"
}

@test "adds item in subfolder" {
  assert_adds_item "${pw1}" "group/${nameA}"
  assert_item_exists "${pw1}" "group/${nameA}"
}

@test "adds item with .gpg extension" {
  assert_adds_item "${pw1}" "${nameA}.gpg"
  assert_item_exists "${pw1}" "${nameA}.gpg"
  run file -b "${PW_KEYCHAIN}/${nameA}.gpg"
  assert_output "data"
}

@test "adds item with .asc extension" {
  assert_adds_item "${pw1}" "${nameA}.asc"
  assert_item_exists "${pw1}" "${nameA}.asc"
  run file -b "${PW_KEYCHAIN}/${nameA}.asc"
  assert_output --partial "PGP message Public-Key Encrypted Session Key"
}

@test "adds item with key id" {
  local keychain="${PW_KEYCHAIN}"
  local key_id="634419040D678764"
  PW_KEYCHAIN="${keychain}:key=${key_id}"
  assert_adds_item "${pw1}" "${nameA}"
  run gpg --batch --pinentry-mode loopback --passphrase "${PW_GPG_PASSWORD}" \
          --list-packets "${keychain}/${nameA}"
  assert_success
  assert_output --partial "keyid ${key_id}"
}

################################################################################
# add another
################################################################################

@test "adds item with different name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_adds_item "${pw2}" "${nameB}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

################################################################################
# add duplicate
################################################################################

assert_item_already_exists() {
  local password="$1"; shift
  run pw add "$@" <<< "${password}"
  assert_failure
  assert_output "gpg: [stdin]: encryption failed: File exists"
}

@test "fails when adding item with existing name" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_item_already_exists "${pw2}" "${nameA}"
}

################################################################################
# rm
################################################################################

@test "removes item" {
  assert_adds_item "${pw1}" "${nameA}"
  assert_adds_item "${pw2}" "${nameB}"
  run pw rm "${nameA}"
  assert_success
  refute_output
  assert_item_not_exists "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

################################################################################
# rm non existing item
################################################################################

@test "fails when deleting non existing item" {
  run pw rm "${nameA}"
  assert_failure
  assert_output "rm: ${PW_KEYCHAIN}/${nameA}: No such file or directory"
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
  assert_adds_item "${pw1}" "${nameA}"
  assert_edits_item "${pw2}" "${nameA}"
  assert_item_exists "${pw2}" "${nameA}"
}

# shellcheck disable=SC2034
@test "edits item with key id" {
  local keychain="${PW_KEYCHAIN}"
  PW_KEYCHAIN="${keychain}:key=634419040D678764"
  assert_adds_item "${pw1}" "${nameA}"

  local key_id="8593E03F5A33D9AC"
  PW_KEYCHAIN="${keychain}:key=${key_id}"
  assert_edits_item "${pw2}" "${nameA}"
  run gpg --batch --pinentry-mode loopback --passphrase "${PW_GPG_PASSWORD}" \
          --list-packets "${keychain}/${nameA}"
  assert_success
  assert_output --partial "keyid ${key_id}"
}

################################################################################
# edit non existing item
################################################################################

@test "adds item when editing non existing item" {
  assert_edits_item "${pw2}" "${nameA}"
  assert_item_exists "${pw2}" "${nameA}"
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
  assert_adds_item "${pw2}" "${nameB}"
  assert_adds_item "${pw1}" "${nameA}"
  run pw ls
  assert_success
  cat << EOF | assert_output -
./${nameA}
./${nameB}
EOF
}

@test "filters .DS_Store" {
  touch "${PW_KEYCHAIN}/.DS_Store"
  run pw ls
  assert_success
  refute_output
}
