# shellcheck disable=SC1091
setup() {
	load 'test_helper/bats-support/load.bash'
	load 'test_helper/bats-assert/load.bash'
	bats_require_minimum_version 1.5.0

	PROGRAM="test-program"
	TEST_CONFIG="${BATS_TEST_TMPDIR}/test.conf"
	source 'lib/config.bash'
	source 'lib/string.bash'
}

write_config() {
	cat > "${TEST_CONFIG}"
}

print_kv() {
	if [[ -n "$1" ]]
	then printf '"%s_%s" : "%s"\n' "$1" "$2" "$3"
	else printf '"%s" : "%s"\n' "$2" "$3"
	fi
}

@test "writes test config file" {
	write_config <<< "test"
	run cat "${TEST_CONFIG}"
	assert_success
	assert_output "test"
}

@test "fails when no config file argument is passed" {
	run --separate-stderr lib_config_parse_section
	assert_failure
	refute_output
	assert_stderr "${PROGRAM} error: no config file argument was passed"
}

@test "fails when config file does not exist" {
	run --separate-stderr lib_config_parse_section "unknown.conf"
	assert_failure
	refute_output
	assert_stderr "${PROGRAM} error: config file not found: unknown.conf"
}

@test "does not print if no section exists" {
	write_config <<EOF
key1 = value1
key2 = value2
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	refute_output
}

@test "does not print if no matching section exists" {
	write_config <<EOF
[section x]
key1 = value1
key2 = value2
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	refute_output
}

@test "prints matching config section" {
	write_config <<EOF
[section 1]
key1 = value1
key2 = value2
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1"
"section 1_key2" : "value2"
EOF
}

@test "only prints matching config section" {
	write_config <<EOF
key0 = value0
[section x]
key1 = value1
key2 = value2
[section 1]
key3 = value3
key4 = value4
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key3" : "value3"
"section 1_key4" : "value4"
EOF
}

@test "prints multiple matching config sections" {
	write_config <<EOF
[section 1]
key1 = value1
key2 = value2
[section x]
key3 = value3
key4 = value4
[section 1]
key5 = value5
key6 = value6
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1"
"section 1_key2" : "value2"
"section 1_key5" : "value5"
"section 1_key6" : "value6"
EOF
}

@test "skips empty lines" {
	write_config <<EOF

[section 1]

key1 = value1

key2 = value2

EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1"
"section 1_key2" : "value2"
EOF
}

@test "skips comment lines" {
	write_config <<EOF
# this is a comment
; this is a comment
[section 1]
key1 = value1
# this is a comment
; this is a comment
key2 = value2
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1"
"section 1_key2" : "value2"
EOF
}

@test "trims indentation" {
	write_config <<EOF
	[section 1]
  	key 1    = 	 value 1
			key 2		=   value 2
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key 1" : "value 1"
"section 1_key 2" : "value 2"
EOF
}

@test "skips empty values" {
	write_config <<EOF
[section 1]
key1 = value1
key2 =
key3 = value3
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1"
"section 1_key3" : "value3"
EOF
}

@test "prints multiline kv pair" {
	write_config <<'EOF'
[section 1]
key1 = value1 line 1 \
       value1 line 2 \
       value1 line 3
key2 = value2 line 1 \
       value2 line 2 \
       value2 line 3
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1 line 1 value1 line 2 value1 line 3"
"section 1_key2" : "value2 line 1 value2 line 2 value2 line 3"
EOF
}

@test "skips empty lines in multiline kv pair" {
	write_config <<'EOF'
[section 1]
key1 = value1 line 1 \

       value1 line 2 \

       value1 line 3
key2 = value2 line 1 \

       value2 line 2 \

       value2 line 3
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1 line 1 value1 line 2 value1 line 3"
"section 1_key2" : "value2 line 1 value2 line 2 value2 line 3"
EOF
}

@test "skips comment lines in multiline kv pair" {
	write_config <<'EOF'
[section 1]
key1 = value1 line 1 \
#      value1 line 2 \
       value1 line 3
key2 = value2 line 1 \
      #  value2 line 2 \
       value2 line 3
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "section 1" print_kv
	assert_success
	cat <<EOF | assert_output -
"section 1_key1" : "value1 line 1 value1 line 3"
"section 1_key2" : "value2 line 1 value2 line 3"
EOF
}

@test "prints kv pair" {
	run lib_config_print_kv "section 1" "key 1" "value 1"
	assert_success
	assert_output "key 1 = value 1"
}

@test "prints entire config section" {
	write_config <<EOF
key1 = value1
key2 = value2

[section 1]
key1 = value1
key2 = value2

[section 2]
key1 = value1
key2 = value2

[section 1]
key3 = value3
key4 = value4
EOF
	run lib_config_parse_section "${TEST_CONFIG}" "" print_kv
	assert_success
	cat <<EOF | assert_output -
"key1" : "value1"
"key2" : "value2"
"section 1_key1" : "value1"
"section 1_key2" : "value2"
"section 2_key1" : "value1"
"section 2_key2" : "value2"
"section 1_key3" : "value3"
"section 1_key4" : "value4"
EOF
}
