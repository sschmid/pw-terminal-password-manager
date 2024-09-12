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
  # shellcheck disable=SC2034
  PW_GPG_PASSWORD="pw_test_password"
  pw::plugin_init

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
  run pw::plugin_init
  assert_failure
  assert_output "${PW_KEYCHAIN} already exists."
}

################################################################################
# get
################################################################################

assert_item_exists() {
  local password="$1"; shift
  run pw::plugin_get "$@"
  assert_success
  assert_output "${password}"
}

assert_item_not_exists() {
  run pw::plugin_get "$@"
  assert_failure
  cat << EOF | assert_output -
gpg: can't open '${PW_KEYCHAIN}/${nameA}': No such file or directory
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
  run pw::plugin_add "$@"
  assert_success
  refute_output
}

@test "adds item with name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}"
}

@test "adds item in subfolder" {
  assert_adds_item "group/${nameA}" "" "${pw1}"
  assert_item_exists "${pw1}" "group/${nameA}"
}

@test "adds item with .gpg extension" {
  assert_adds_item "${nameA}.gpg" "" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}.gpg"
  run file -b "${PW_KEYCHAIN}/${nameA}.gpg"
  assert_output "data"
}

@test "adds item with .asc extension" {
  assert_adds_item "${nameA}.asc" "" "${pw1}"
  assert_item_exists "${pw1}" "${nameA}.asc"
  run file -b "${PW_KEYCHAIN}/${nameA}.asc"
  assert_output --partial "PGP message Public-Key Encrypted Session Key"
}

################################################################################
# add another
################################################################################

@test "adds item with different name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_adds_item "${nameB}" "" "${pw2}"
  assert_item_exists "${pw1}" "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

################################################################################
# add duplicate
################################################################################

@test "fails when adding item with existing name" {
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_add "${nameA}" "" "${pw2}"
  assert_failure
  assert_output "gpg: [stdin]: encryption failed: File exists"
}

################################################################################
# rm
################################################################################

@test "removes item" {
  assert_adds_item "${nameA}" "" "${pw1}"
  assert_adds_item "${nameB}" "" "${pw2}"
  run pw::plugin_rm "${nameA}"
  assert_success
  refute_output
  assert_item_not_exists "${nameA}"
  assert_item_exists "${pw2}" "${nameB}"
}

################################################################################
# rm non existing item
################################################################################

@test "fails when deleting non existing item" {
  run pw::plugin_rm "${nameA}"
  assert_failure
  assert_output "rm: ${PW_KEYCHAIN}/${nameA}: No such file or directory"
}

################################################################################
# edit
################################################################################

@test "edits item" {
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_edit "${nameA}" "" "${pw2}"
  assert_success
  refute_output
  assert_item_exists "${pw2}" "${nameA}"
}

################################################################################
# edit non existing item
################################################################################

@test "adds item when editing non existing item" {
  run pw::plugin_edit "${nameA}" "" "${pw2}"
  assert_success
  refute_output
  assert_item_exists "${pw2}" "${nameA}"
}

################################################################################
# list item
################################################################################

@test "lists no items" {
  run pw::plugin_ls
  assert_success
  refute_output
}

@test "lists sorted items" {
  assert_adds_item "${nameB}" "" "${pw2}"
  assert_adds_item "${nameA}" "" "${pw1}"
  run pw::plugin_ls
  assert_success
  cat << EOF | assert_output -
./${nameA}
./${nameB}
EOF
}

@test "filters .DS_Store" {
  touch "${PW_KEYCHAIN}/.DS_Store"
  run pw::plugin_ls
  assert_success
  refute_output
}
