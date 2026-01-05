lib_config_parse_section() {
	if (( ! $# )); then
		printf "%s error: no config file argument was passed\n" "${PROGRAM}" >&2
		exit 1
	fi

	local config_path="$1"
	if [[ ! -f "${config_path}" ]]; then
		printf "%s error: config file not found: %s\n" "${PROGRAM}" "${config_path}" >&2
		exit 1
	fi

	local requested="$2" callback="$3"
	local line next_line section="" key value
	while IFS= read -r line; do
		line="$(lib_string_trim "${line}")"
		[[ -z ${line} ]] && continue
		[[ "${line}" == "#"* || "${line}" == ";"* ]] && continue
		[[ "${line}" == \[*\] ]] && section="${line//[\[\]]/}" && continue
		if [[ -z "${requested}" ]] || [[ "${section}" == "${requested}" ]]; then
			while [[ "${line}" == *\\ ]]; do
				IFS= read -r next_line
				next_line="$(lib_string_trim "${next_line}")"
				[[ -z ${next_line} ]] && continue
				[[ "${next_line}" == "#"* || "${next_line}" == ";"* ]] && continue
				line="${line%\\}${next_line}"
			done
			key="$(lib_string_trim "${line%%=*}")"
			value="$(lib_string_trim "${line#*=}")"
			[[ -z ${value} ]] && continue
			"${callback}" "${section}" "${key}" "${value}"
		fi
	done < "${config_path}"
}

lib_config_print_kv() {
	printf "%s%s%s = %s\n" "${COLOR_BLUE}" "$2" "${COLOR_RESET}" "$3"
}
