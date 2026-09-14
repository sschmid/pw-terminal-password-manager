# shellcheck disable=SC1091
setup() {
	load 'test_helper/bats-support/load.bash'
	load 'test_helper/bats-assert/load.bash'
	PATH="${BATS_TEST_DIRNAME}/../lib:${PATH}"
}

@test "trim handles empty string" {
	run string_trim ""
	assert_success
	refute_output
}

@test "trim handles character" {
	run string_trim "a"
	assert_success
	assert_output "a"
}

@test "trim handles word" {
	run string_trim "abc"
	assert_success
	assert_output "abc"
}

@test "trims leading space" {
	run string_trim " abc"
	assert_success
	assert_output "abc"
}

@test "trims trailing space" {
	run string_trim "abc "
	assert_success
	assert_output "abc"
}

@test "trims leading and trailing space" {
	run string_trim " abc "
	assert_success
	assert_output "abc"
}

@test "trims multiple leading and trailing spaces" {
	run string_trim " 	 a b c 	 "
	assert_success
	assert_output "a b c"
}
