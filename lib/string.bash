lib_string_trim() {
	local line="$1"
	line="${line#"${line%%[![:space:]]*}"}"
	line="${line%"${line##*[![:space:]]}"}"
	printf '%s' "${line}"
}
