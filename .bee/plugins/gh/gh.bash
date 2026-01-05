gh::run_rerun_retry() {
	local run_id
	echo -n "🤖 Fetching latest run: "
	run_id="$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')"
	echo "${run_id}"

	for i in {1..5}; do
		echo "🔁 Attempt $i: Watching run ${run_id}..."
		if gh run watch --exit-status "${run_id}"; then
			echo "✅ Success on attempt $i!"
			return 0
		else
			echo "❌ Run failed. Retrying failed jobs..."
			sleep 10
			gh run rerun "${run_id}" --failed
		fi
	done

	echo "🤖 Giving up after 5 attempts!"
	return 1
}
