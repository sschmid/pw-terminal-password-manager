for file in lib/*.bash; do
	# shellcheck disable=SC1090
	[[ "$(basename -- "${file}")" == "all.bash" ]] || source "${file}"
done
