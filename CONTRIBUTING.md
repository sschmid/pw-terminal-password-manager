# Contributing to `pw`

`pw` is a bash-based password manager. Tests are written using [bats-core](https://github.com/bats-core/bats-core).

---

## Setup

Clone the repository:

```bash
git clone https://github.com/sschmid/pw-terminal-password-manager.git pw
cd pw
```

Verify that `pw` runs:

```bash
src/pw -h
```

You should see the help output.

---

## Development Environment

### Option 1: Local setup

Ensure required dependencies are installed. See [requirements](README.md#requirements).

Example for Debian/Ubuntu:

```bash
sudo apt-get update && sudo apt-get install $(cat DEPENDENCIES)
```

---

### Option 2: Dev Container (recommended)

This repository includes a Dev Container configuration for a reproducible development environment.

Requirements:
- A container runtime (e.g. Podman, Docker, or Apple Containers)
- An editor or IDE with Dev Container support (e.g. VS Code, Zed, JetBrains IDEs)

Once inside the container, everything works as usual:

```bash
src/pw -h
```

This approach avoids installing dependencies locally and ensures consistent environments across contributors and CI.

---

## Running Tests

Run the full test suite:

```bash
test/run
```

Run a specific test file:

```bash
test/run test/pw.bats
```

Run tests including manual tests:

```bash
test/run -m
```

Run tests in parallel (requires GNU parallel):

```bash
test/run -j 4
```

Run tests in containers (Podman, Docker, or Apple container runtime):

```bash
test/run -p alpine
```

Run tests across all container configurations:

```bash
test/run -a
```

---

## Linting

Run shellcheck:

```bash
test/shellcheck
```

---

## CI

`pw` uses GitHub Actions to run tests and shellcheck on every push to `main`.

See: [.github/workflows/ci.yml](.github/workflows/ci.yml)

Test coverage reports are generated and uploaded to Coveralls:
https://coveralls.io/github/sschmid/pw-terminal-password-manager

---

## Releases

Releases are automated using [bee](https://github.com/sschmid/bee).

Release logic is defined in [.bee/plugins/release/release.bash](.bee/plugins/release/release.bash)

### Typical release flow

- Ensure you are on the `main` branch
- Ensure `bee` is installedda
- Run `bee install`
- Prepare release notes in `CHANGES.md`
- Bump version:

```bash
bee semver major
bee semver minor
bee semver patch
```

- Publish release:

```bash
bee release publish
```

---

### What happens during release

- `CHANGES.md` is merged into `CHANGELOG.md` with version and date
- A Git release commit is created, followed by a tag and push
- GitHub release is created from `CHANGES.md`
- CI is triggered and must pass
- Build artifacts are downloaded from CI
- Artifacts are attached to the GitHub release
