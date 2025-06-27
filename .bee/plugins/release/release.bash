RELEASE_RUN_ID=""

release::publish() {
  changelog::merge
  git add .
  local version
  version="$(semver::read)"
  git commit -m "Release ${version}"
  git push
  git tag "${version}"
  git push --tags
  github::create_release

  _set_release_run_id "${version}"
  _wait_for_run
  _download_artifact "pw"
  _upload_assets "${version}"
}

_wait_for_run() {
  # gh cli
  if ! gh run watch --compact --exit-status "${RELEASE_RUN_ID}"; then
    echo "Run ${RELEASE_RUN_ID} failed."
    return 1
  fi

  # github api
  # local conclusion
  # while :; do
  #   echo -n "Waiting for run ${RELEASE_RUN_ID}: "
  #   conclusion=$(github::runs "/${RELEASE_RUN_ID}" | jq -r '.conclusion')
  #   echo "${conclusion}"
  #   case "${conclusion}" in
  #     cancelled | failure | timed_out)
  #       echo "Run did not complete successfully." >&2
  #       return 1
  #       ;;
  #     success)
  #       echo "Run completed successfully."
  #       break
  #       ;;
  #     *)
  #       echo "Retrying in 30 seconds..."
  #       sleep 30
  #       continue
  #       ;;
  #   esac
  # done
}

_set_release_run_id() {
  [[ -n "${RELEASE_RUN_ID}" ]] && return
  local tag="$1" run run_id run_name
  while :; do
    echo -n "Fetching latest run: "
    run="$(github::runs "?per_page=1" | jq -r '.workflow_runs[0] | "\(.id) \(.display_title)"')"
    run_id="${run%% *}"
    run_name="${run#* }"
    echo "[${run_id}] ${run_name}"

    if [[ "${run_name}" != "Release ${tag}" ]]; then
      echo "Latest run is not 'Release ${tag}'! Retrying in 5 seconds..."
      sleep 5
      continue
    fi

    RELEASE_RUN_ID="${run_id}"
    break
  done
}

_download_artifact() {
  local artifact_name="$1" artifact_id
  artifact_id="$(github::artifacts "${RELEASE_RUN_ID}" \
    | jq -r --arg name "${artifact_name}" '.artifacts[] | select(.name == $name) | .id')"

  mkdir -p dist
  echo "Downloading artifact: ${artifact_name} [${artifact_id}]"
  github::download "${artifact_id}" "dist/${artifact_name}"
}

_upload_assets() {
  local tag="$1" release_id
  release_id="$(github::releases "/tags/${tag}" | jq -r '.id')"
  github::upload_assets "${release_id}"
}
