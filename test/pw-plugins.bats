# shellcheck disable=SC2030,SC2031
setup() {
	load 'pw'
	_setup
	_config_append_with_test_plugins
	export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/test keychain.test"
	KEYCHAIN_OPTIONS="key1=value1,key2=value2"
	KEYCHAIN_PASSWORD=" keychain password "
}

################################################################################
# init
################################################################################

@test "inits keychain" {
	run pw init "new keychain.test"
	assert_success
	assert_output "test init <> <new keychain.test>"
}

@test "inits keychain and separates options" {
	run pw init "new keychain.test:${KEYCHAIN_OPTIONS}"
	assert_success
	assert_output "test init <${KEYCHAIN_OPTIONS}> <new keychain.test>"
}

@test "inits keychain with uppercase extension" {
	run pw init "new keychain.TEST"
	assert_success
	assert_output "test init <> <new keychain.TEST>"
}

@test "init fails when keychain already exists" {
	local keychain="${BATS_TEST_TMPDIR}/new keychain.test"
	touch "${keychain}"

	run pw init "${keychain}"
	assert_failure
	assert_output "pw: ${keychain} already exists."
}

################################################################################
# get
################################################################################

@test "prints item password" {
	run pw -p -k "${PW_KEYCHAIN}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
	assert_success
	assert_output "test get <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "prints item password with -pk" {
	run pw -pk "${PW_KEYCHAIN}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
	assert_success
	assert_output "test get <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "prints item password with options and keychain password" {
	export PW_TEST_PLUGIN_KEYCHAIN_PASSWORD=1
	run pw -pk "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
	assert_success
	assert_output "test get <${KEYCHAIN_OPTIONS}> <${KEYCHAIN_PASSWORD}> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

################################################################################
# add
################################################################################

@test "adds item" {
	run pw add "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}" <<< "${PW_1}"
	assert_success
	assert_output "test add <> <> <${PW_KEYCHAIN}> <${PW_1}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}> <${MULTI_LINE_NOTES}>"
}

@test "adds item with options and keychain password" {
	export PW_TEST_PLUGIN_KEYCHAIN_PASSWORD=1
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" add "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" "${MULTI_LINE_NOTES}" <<< "${PW_1}"
	assert_success
	assert_output "test add <${KEYCHAIN_OPTIONS}> <${KEYCHAIN_PASSWORD}> <${PW_KEYCHAIN}> <${PW_1}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}> <${MULTI_LINE_NOTES}>"
}

# bats test_tags=tag:manual_test
@test "prompts password when no stdin" {
	_skip_manual_test "' test password ' twice (with leading whitespace)"
	run pw add "${NAME_A}"
	assert_success
	cat << EOF | assert_output -
Enter password for '${NAME_A}' (leave empty to generate password):
Retype password for '${NAME_A}':
test add <> <> <${PW_KEYCHAIN}> < test password > <${NAME_A}> <> <> <>
EOF
}

# bats test_tags=tag:manual_test
@test "add prompts password and fails if retyped password does not match" {
	_skip_manual_test "'test 1' and 'test 2'"
	run pw add "${NAME_A}"
	assert_failure
	cat << EOF | assert_output -
Enter password for '${NAME_A}' (leave empty to generate password):
Retype password for '${NAME_A}':
Error: the entered passwords do not match.
EOF
}

# bats test_tags=tag:manual_test
@test "generates password when empty" {
	_skip_manual_test "nothing"
	export PW_GEN_LENGTH=5
	export PW_GEN_CLASS="1"
	run pw -p add "${NAME_A}"
	assert_success
	cat << EOF | assert_output -
Enter password for '${NAME_A}' (leave empty to generate password):
test add <> <> <${PW_KEYCHAIN}> <11111> <${NAME_A}> <> <> <>
EOF
}

# bats test_tags=tag:manual_test
@test "adds item interactively" {
	_skip_manual_test "name, account, url, notes (end with Ctrl+D), then pass, pass"
	run pw add
	assert_success
	cat << EOF | assert_output -
Title: Username: URL: Notes: Enter multi-line input (end with Ctrl+D):
Enter password for 'name' (leave empty to generate password):
Retype password for 'name':
test add <> <> <${PW_KEYCHAIN}> <pass> <name> <account> <url> <notes>
EOF
}

################################################################################
# show
################################################################################

@test "prints item details" {
	run pw -p show "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
	assert_success
	assert_output "test show <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "prints item details with options and keychain password" {
	export PW_TEST_PLUGIN_KEYCHAIN_PASSWORD=1
	run pw -pk "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" show "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
	assert_success
	assert_output "test show <${KEYCHAIN_OPTIONS}> <${KEYCHAIN_PASSWORD}> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

################################################################################
# rm
################################################################################

@test "removes item" {
	run pw rm "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
	assert_success
	assert_output "test rm <> <> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "removes item with options and keychain password" {
	export PW_TEST_PLUGIN_KEYCHAIN_PASSWORD=1
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" rm "${NAME_A}" "${ACCOUNT_A}" "${URL_A}"
	assert_success
	assert_output "test rm <${KEYCHAIN_OPTIONS}> <${KEYCHAIN_PASSWORD}> <${PW_KEYCHAIN}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

# bats test_tags=tag:manual_test
@test "removes item interactively" {
	_skip_manual_test "select 'name 2', then enter 'y'"
	export PW_TEST_PLUGIN_LS=1
	read -rsp "Press enter to continue ..."
	run pw rm
	assert_success
	cat << EOF | assert_output -
Do you really want to remove 'name 2' 'account 2' from '${PW_KEYCHAIN}'? (y / N): test rm <> <> <${PW_KEYCHAIN}> <name 2> <account 2> <url 2>
EOF
}

################################################################################
# edit
################################################################################

@test "edits item" {
	run pw edit "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" <<< "${PW_2}"
	assert_success
	assert_output "test edit <> <> <${PW_KEYCHAIN}> <${PW_2}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "edits item with options and keychain password" {
	export PW_TEST_PLUGIN_KEYCHAIN_PASSWORD=1
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" edit "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" <<< "${PW_2}"
	assert_success
	assert_output "test edit <${KEYCHAIN_OPTIONS}> <${KEYCHAIN_PASSWORD}> <${PW_KEYCHAIN}> <${PW_2}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

# bats test_tags=tag:manual_test
@test "edit prompts password and fails if retyped password does not match" {
	_skip_manual_test "'test 1' and 'test 2'"
	run pw edit "${NAME_A}"
	assert_failure
	cat << EOF | assert_output -
Enter password for '${NAME_A}' (leave empty to generate password):
Retype password for '${NAME_A}':
Error: the entered passwords do not match.
EOF
}

################################################################################
# rename
################################################################################

@test "renames item" {
	run pw mv "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" <<< "${NAME_B}"
	assert_success
	assert_output "test mv <> <> <${PW_KEYCHAIN}> <${NAME_B}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

@test "renames item with options and keychain password" {
	export PW_TEST_PLUGIN_KEYCHAIN_PASSWORD=1
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" mv "${NAME_A}" "${ACCOUNT_A}" "${URL_A}" <<< "${NAME_B}"
	assert_success
	assert_output "test mv <${KEYCHAIN_OPTIONS}> <${KEYCHAIN_PASSWORD}> <${PW_KEYCHAIN}> <${NAME_B}> <${NAME_A}> <${ACCOUNT_A}> <${URL_A}>"
}

################################################################################
# list item
################################################################################

@test "lists items" {
	run pw ls
	assert_success
	assert_output "test ls <> <> <${PW_KEYCHAIN}> <default>"
}

@test "lists items with options, keychain password and format" {
	export PW_TEST_PLUGIN_KEYCHAIN_PASSWORD=1
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" ls fzf
	assert_success
	assert_output "test ls <${KEYCHAIN_OPTIONS}> <${KEYCHAIN_PASSWORD}> <${PW_KEYCHAIN}> <fzf>"
}

@test "fails when ls fails" {
	export PW_TEST_PLUGIN_FAIL=1
	run pw
	assert_failure
	refute_output
}

################################################################################
# lock
################################################################################

@test "locks keychain" {
	run pw lock
	assert_success
	assert_output "test lock <> <${PW_KEYCHAIN}>"
}

@test "locks keychain with options" {
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" lock
	assert_success
	assert_output "test lock <${KEYCHAIN_OPTIONS}> <${PW_KEYCHAIN}>"
}

@test "unlocks keychain" {
	run pw unlock
	assert_success
	assert_output "test unlock <> <${PW_KEYCHAIN}>"
}

@test "unlocks keychain with options" {
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" unlock
	assert_success
	assert_output "test unlock <${KEYCHAIN_OPTIONS}> <${PW_KEYCHAIN}>"
}

@test "opens keychain" {
	run pw open
	assert_success
	assert_output "test open <> <${PW_KEYCHAIN}>"
}

@test "opens keychain with options" {
	run pw -k "${PW_KEYCHAIN}:${KEYCHAIN_OPTIONS}" open
	assert_success
	assert_output "test open <${KEYCHAIN_OPTIONS}> <${PW_KEYCHAIN}>"
}

################################################################################
# fzf preview
################################################################################

# bats test_tags=tag:manual_test
@test "runs fzf preview in bash" {
	_skip_manual_test "activate preview and select 'name 2'. Preview should look fine with no errors."
	export PW_TEST_PLUGIN_LS=1
	read -rsp "Press enter to continue ..."
	run pw -p
	assert_success
	assert_output "test get <> <> <${PW_KEYCHAIN}> <name 2> <account 2> <url 2>"
}
