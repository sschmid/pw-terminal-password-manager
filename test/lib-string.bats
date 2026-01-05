# shellcheck disable=SC1091
setup() {
	load 'test_helper/bats-support/load.bash'
	load 'test_helper/bats-assert/load.bash'
	source 'lib/string.bash'
}

@test "trim handles emty string" {
	run lib_string_trim ""
	assert_success
	refute_output
}

@test "trim handles character" {
	run lib_string_trim "a"
	assert_success
	assert_output "a"
}

@test "trim handles word" {
	run lib_string_trim "abc"
	assert_success
	assert_output "abc"
}

@test "trims leading space" {
	run lib_string_trim " abc"
	assert_success
	assert_output "abc"
}

@test "trims trailing space" {
	run lib_string_trim "abc "
	assert_success
	assert_output "abc"
}

@test "trims leading and trailing space" {
	run lib_string_trim " abc "
	assert_success
	assert_output "abc"
}

@test "trims multiple leading and trailing spaces" {
	run lib_string_trim " 	 abc 	 "
	assert_success
	assert_output "abc"
}
