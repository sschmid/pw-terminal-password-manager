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
  release::upload "${version}"
}

release::upload() {
  local tag="$1"

  # Choose run to download artifacts from
  local -i run_id
  run_id="$(github::runs \
    | jq -r '.workflow_runs[] | "\(.id) [\(.conclusion)]: \(.display_title)"' \
    | fzf --header="Select a run to download artifacts from" \
    | awk '{print $1}')"

  # Choose artifact to download
  local artifact
  artifact="$(github::artifacts ${run_id} \
    | jq -r '.artifacts[] | "\(.id) \(.name)"' \
    | fzf --header="Select an artifact to download")"

  echo "Downloading artifact"
  mkdir -p dist
  github::download "$(awk '{print $1}' <<< "${artifact}")" "dist/$(awk '{print $2}' <<< "${artifact}")"

  local release_id
  release_id="$(github::releases "/tags/${tag}" | jq -r '.id')"

  echo "Uploading assets to release ${tag} (${release_id})"
  github::upload_assets "${release_id}"
}
