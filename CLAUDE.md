# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Testing framework for [Project Hummingbird](https://gitlab.com/redhat/hummingbird/containers), which builds minimal, hardened container images with near-zero vulnerabilities. This repo contains test plans for 44 container images and automated tests for 5 priority images (curl, jq, nginx, python-3-13, nodejs-22). Images are hosted on [Quay.io](https://quay.io/organization/hummingbird).

## Key Concept: Drop-in Replacement Testing

Hummingbird images are minimal and hardened — they typically lack a shell (`/bin/sh`), filesystem utilities, and other tools found in mainstream images. **The goal of this test suite is to validate that these images work as drop-in replacements for their mainstream counterparts in real service stacks.**

This means:
- **Never modify the Hummingbird images.** No custom Dockerfiles that use `FROM quay.io/hummingbird/...` as a base — these images have no shell, so `RUN` commands will fail.
- **Use `podman-compose`** (or `docker-compose`) to orchestrate tests. Mount configuration and app code as volumes. Use builder init services for dependency installation.
- **Test the image as-is**, the way a real user would deploy it in production (Kubernetes, Compose, etc.).

## Running Tests

Tests require a container runtime (podman or docker).

```bash
# Run all Phase 1 basic tests
phase1-tests/run-all-tests.sh

# Run a single image's basic tests
cd phase1-tests/<image-name>
bash test.sh

# Run a single image's integration tests (compose-based)
cd phase1-tests/<image-name>/integration
bash test-integration.sh

# Use docker instead of podman (default)
TEST_ENGINE=docker bash test.sh
TEST_ENGINE=docker bash test-integration.sh
```

## Architecture

### Test Plans (44 files)
- **`test-<image>.md`** (root) — Documentation-only test plans for each image, with standardized sections for test checklists, command templates, and results tracking.

### Basic Tests (Phase 1)
- **`phase1-tests/<image>/test.sh`** (5 images) — Quick smoke tests that run the image directly via `podman run`. 4 tests per image covering version checks, basic functionality, and simple I/O.
- **`phase1-tests/run-all-tests.sh`** — Aggregates all basic tests, reports overall pass/fail.

### Integration Tests (compose-based)
- **`phase1-tests/<image>/integration/`** — Each contains:
  - `compose.yaml` — Defines the service stack. The Hummingbird image is used **untouched**.
  - `test-integration.sh` — Orchestrates `podman-compose up/down` and validates behavior.
  - App code and config files — volume-mounted into the container at runtime.

Integration test patterns by image type:

| Pattern | Images | How it works |
|---------|--------|--------------|
| **Utility** | curl, jq | Run the image directly via `compose run` with arguments or volume-mounted data files |
| **Web server** | nginx | Volume-mount config (`nginx.conf`) and static files, start as a service |
| **Runtime + deps** | python, nodejs | Builder init service installs deps (pip/npm) into a shared volume, then the Hummingbird image runs the app with deps mounted |

## Test Conventions

- All test scripts use `set -euo pipefail` and exit 0 on success, 1 on failure
- Container engine is configurable via `TEST_ENGINE` env var (defaults to podman)
- Integration tests use `${TEST_ENGINE}-compose` (podman-compose or docker-compose)
- Cleanup via `trap` ensures `compose down --volumes --remove-orphans` runs on exit
- Service tests include retry loops for startup readiness
- Images are pulled from `quay.io/hummingbird/<image-name>`

## Onboarding a New Image Test

1. Create `test-<image>.md` in the repo root with the standardized test plan template.
2. Create `phase1-tests/<image>/test.sh` with 4 basic smoke tests (version, basic I/O, etc.).
3. Create `phase1-tests/<image>/integration/` with:
   - `compose.yaml` — use the Hummingbird image **as-is** (no Dockerfile). Mount config/code as volumes.
   - For runtime images needing deps: add a builder init service using the mainstream image to install deps into a shared volume.
   - `test-integration.sh` — use `${TEST_ENGINE}-compose` to start services and run assertions.
   - `README.md` — document the approach and what's being tested.
4. Add the image to `phase1-tests/run-all-tests.sh`.

## CI/CD

GitHub Actions workflow at `.github/workflows/phase1-tests.yml` runs Phase 1 tests on push/PR to main. Requires `QUAY_USERNAME` and `QUAY_PASSWORD` repository secrets for Quay.io authentication.
