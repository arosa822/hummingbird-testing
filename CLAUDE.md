# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Testing framework for [Project Hummingbird](https://gitlab.com/redhat/hummingbird/containers), which builds minimal, hardened container images with near-zero vulnerabilities. This repo contains test plans for 44 container images and automated Phase 1 build verification tests for 5 priority images (curl, jq, nginx, python-3-13, nodejs-22). Images are hosted on [Quay.io](https://quay.io/organization/hummingbird).

**Important:** Hummingbird images are minimal and typically lack `/bin/sh` and filesystem utilities. Keep this in mind when writing tests or Dockerfiles.

## Running Tests

Tests require a container runtime (podman or docker).

```bash
# Run all Phase 1 tests
bash phase1-tests/run-all-tests.sh

# Run a single image's tests
bash phase1-tests/<image-name>/test.sh

# Use docker instead of podman (default)
TEST_ENGINE=docker bash phase1-tests/curl/test.sh
```

## Repository Structure

- **`phase1-tests/<image>/test.sh`** — 4 smoke tests per image (version, basic I/O, features, real-world usage). Uses `set -euo pipefail`, cleanup traps for stateful services.
- **`phase1-tests/run-all-tests.sh`** — Runs all 5 image tests sequentially, reports pass/fail.
- **`docs/test-plans/`** — Documentation-only test plan templates for all 44 images.
- **`docs/`** — Supporting docs (prerequisites, credentials setup, test strategy, session notes).
- **`scripts/`** — Automation helpers (test result fetcher, onboarding scripts).

## Test Conventions

- All test scripts use `set -euo pipefail` and exit 0 on success, 1 on failure
- Container engine is configurable via `TEST_ENGINE` env var (defaults to podman)
- Stateful containers (e.g., nginx) use `trap` for cleanup on exit
- Network-dependent tests include retry logic
- Images are pulled from `quay.io/hummingbird/<image-name>`

## Image Naming

Hummingbird uses `{repository}:{stream}`, not `{directory-name}:latest`:
- `python-3-13` dir → `quay.io/hummingbird/python:3.13`
- `nodejs-22` dir → `quay.io/hummingbird/nodejs:22`
- `curl` dir → `quay.io/hummingbird/curl:latest`

## CI/CD

GitHub Actions workflow at `.github/workflows/phase1-tests.yml` runs on push/PR to main. Requires `QUAY_USERNAME` and `QUAY_PASSWORD` repository secrets.
