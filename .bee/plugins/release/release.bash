release::archive() {
  {
    find examples plugins src -type f ! -name '.DS_Store' -print0
    printf '%s\0' CHANGELOG.md LICENSE.txt README.md version.txt
  } | tar --null -czf pw.tar.gz --files-from=-
}

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
}
