# Welcome to `pw`

`pw` is a bash program and tests are written using `bats`, see https://github.com/bats-core/bats-core

## Setup

Get the source code:

```bash
git clone https://github.com/sschmid/pw-terminal-password-manager.git pw
```

Verify `pw` works:
- you should see the `pw` help

```bash
cd pw
src/pw -h
```

## Run Tests

Run tests:

```bash
test/run
```

Run a specific test:

```bash
test/run test/pw.bats
```

Run tests including manual tests:

```bash
test/run -m
```

Run tests in parallel:
- requires GNU parallel
- test output is delayed to keep test output ordered

```bash
test/run -j 4
```

Run tests in a container (Docker, Podman):
- see [Dockerfiles](docker)

```bash
test/run -p alpine
```

Run tests in all containers:
- see [Dockerfiles](docker)

```bash
test/run -a
```

Run shellcheck:

```bash
test/shellcheck
```

## CI

`pw` uses GitHub Actions to run tests and shellcheck on every commit and pull request,
see [ci.yml](.github/workflows/ci.yml)

Test coverage reports are generated and uploaded to [Coveralls](https://coveralls.io/github/sschmid/pw-terminal-password-manager)

## Create a release

`pw` uses [bee](https://github.com/sschmid/bee) to automatically prepare and create releases,
see [bee release plugin](.bee/plugins/release/release.bash)

### Example:

- make sure you're on the `main` branch
- make sure you have `bee` installed and run `bee install` in the repository
- create `CHANGES.md` and specify the changes as to be seen in a GitHub release
- bump the version with `bee semver major`, `bee semver minor` or `bee semver patch`
- run `bee release publish`

This will:
- merge `CHANGES.md` into `CHANGELOG.md`, while generating a new version section
  with date and update the links at the bottom of the file
- commit, tag, and push
- create a GitHub release with the content of `CHANGES.md`
- wait for the CI run to finish and succeed
- download the artifacts from the CI run
- upload the artifacts to the GitHub release
