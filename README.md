# Hummingbird Container Images - Testing Framework

Automated testing for [Red Hat Hummingbird](https://gitlab.com/redhat/hummingbird/containers) minimal, hardened container images.

[![Phase 1 Tests](https://github.com/arosa822/hummingbird-testing/actions/workflows/phase1-tests.yml/badge.svg)](https://github.com/arosa822/hummingbird-testing/actions)

- **Registry:** https://quay.io/organization/hummingbird
- **Docs:** https://hummingbird-project.io/

---

## Quick Start

```bash
git clone https://github.com/arosa822/hummingbird-testing
cd hummingbird-testing

# Login to quay.io
podman login quay.io

# Run all tests
bash phase1-tests/run-all-tests.sh

# Run a single image test
bash phase1-tests/curl/test.sh

# Use docker instead of podman
TEST_ENGINE=docker bash phase1-tests/curl/test.sh
```

---

## Image Catalog

44 images across 7 categories. **42 tested** in Phase 1 (minio, minio-client, and bootc-os require private registry access).

### Utilities & Tools

| Image | Registry | Status |
|-------|----------|--------|
| [curl](docs/test-details.md#curl) | `quay.io/hummingbird/curl:latest` | Tested |
| [jq](docs/test-details.md#jq) | `quay.io/hummingbird/jq:latest` | Tested |
| [git](docs/test-details.md#git) | `quay.io/hummingbird/git:latest` | Tested |
| [memcached](docs/test-details.md#memcached) | `quay.io/hummingbird/memcached:latest` | Tested |
| minio | `quay.io/hummingbird/minio:latest` | |
| minio-client | `quay.io/hummingbird/minio-client:latest` | |

### Web Servers

| Image | Registry | Status |
|-------|----------|--------|
| [nginx](docs/test-details.md#nginx) | `quay.io/hummingbird/nginx:latest` | Tested |
| [caddy](docs/test-details.md#caddy) | `quay.io/hummingbird/caddy:latest` | Tested |
| [haproxy](docs/test-details.md#haproxy) | `quay.io/hummingbird/haproxy:latest` | Tested |
| [httpd](docs/test-details.md#httpd) | `quay.io/hummingbird/httpd:latest` | Tested |

### Language Runtimes

| Image | Registry | Status |
|-------|----------|--------|
| [python-3-13](docs/test-details.md#python-3-13) | `quay.io/hummingbird/python:3.13` | Tested |
| [nodejs-22](docs/test-details.md#nodejs-22) | `quay.io/hummingbird/nodejs:22` | Tested |
| [python-3-11](docs/test-details.md#python-3-11) | `quay.io/hummingbird/python:3.11` | Tested |
| [python-3-12](docs/test-details.md#python-3-12) | `quay.io/hummingbird/python:3.12` | Tested |
| [python-3-14](docs/test-details.md#python-3-14) | `quay.io/hummingbird/python:3.14` | Tested |
| [nodejs-20](docs/test-details.md#nodejs-20) | `quay.io/hummingbird/nodejs:20` | Tested |
| [nodejs-24](docs/test-details.md#nodejs-24) | `quay.io/hummingbird/nodejs:24` | Tested |
| nodejs-25 | `quay.io/hummingbird/nodejs:25` | Tested |
| [go-1-25](docs/test-details.md#go-1-25) | `quay.io/hummingbird/go:1.25` | Tested |
| [go-1-26](docs/test-details.md#go-1-26) | `quay.io/hummingbird/go:1.26` | Tested |
| [rust](docs/test-details.md#rust) | `quay.io/hummingbird/rust:latest` | Tested |
| [php](docs/test-details.md#php) | `quay.io/hummingbird/php:latest` | Tested |
| ruby-3-3 | `quay.io/hummingbird/ruby:3.3` | Tested |
| [ruby-3-4](docs/test-details.md#ruby-3-4) | `quay.io/hummingbird/ruby:3.4` | Tested |
| ruby-4-0 | `quay.io/hummingbird/ruby:4.0` | Tested |
| [openjdk-21](docs/test-details.md#openjdk-21) | `quay.io/hummingbird/openjdk:21` | Tested |
| openjdk-25 | `quay.io/hummingbird/openjdk:25` | Tested |

### .NET / ASP.NET

| Image | Registry | Status |
|-------|----------|--------|
| aspnet-runtime-8-0 | `quay.io/hummingbird/aspnet-runtime:8.0` | Tested |
| aspnet-runtime-9-0 | `quay.io/hummingbird/aspnet-runtime:9.0` | Tested |
| aspnet-runtime-10-0 | `quay.io/hummingbird/aspnet-runtime:10.0` | Tested |
| dotnet-runtime-8-0 | `quay.io/hummingbird/dotnet-runtime:8.0` | Tested |
| dotnet-runtime-9-0 | `quay.io/hummingbird/dotnet-runtime:9.0` | Tested |
| dotnet-runtime-10-0 | `quay.io/hummingbird/dotnet-runtime:10.0` | Tested |
| dotnet-sdk-8-0 | `quay.io/hummingbird/dotnet-sdk:8.0` | Tested |
| dotnet-sdk-9-0 | `quay.io/hummingbird/dotnet-sdk:9.0` | Tested |
| dotnet-sdk-10-0 | `quay.io/hummingbird/dotnet-sdk:10.0` | Tested |

### Databases

| Image | Registry | Status |
|-------|----------|--------|
| [mariadb-10-11](docs/test-details.md#mariadb-10-11) | `quay.io/hummingbird/mariadb:10.11` | Tested |
| mariadb-11-8 | `quay.io/hummingbird/mariadb:11.8` | Tested |
| [postgresql](docs/test-details.md#postgresql) | `quay.io/hummingbird/postgresql:latest` | Tested |
| [valkey](docs/test-details.md#valkey) | `quay.io/hummingbird/valkey:latest` | Tested |

### Application Servers

| Image | Registry | Status |
|-------|----------|--------|
| [tomcat-10](docs/test-details.md#tomcat-10) | `quay.io/hummingbird/tomcat:10` | Tested |
| tomcat-11 | `quay.io/hummingbird/tomcat:11` | Tested |

### Specialized

| Image | Registry | Status |
|-------|----------|--------|
| core-runtime | `quay.io/hummingbird/core-runtime:latest` | Tested |
| bootc-os | `quay.io/hummingbird/bootc-os:latest` | Private |
| xcaddy | `quay.io/hummingbird/xcaddy:latest` | Tested |

---

## Test Structure

```
phase1-tests/
├── run-all-tests.sh            # Run all 42 image tests
├── curl/test.sh                # 4 smoke tests each
├── jq/test.sh
├── nginx/test.sh
├── python-3-13/test.sh + test_script.py
├── nodejs-22/test.sh + test_script.js
├── git/test.sh
├── httpd/test.sh
├── caddy/test.sh
├── haproxy/test.sh + haproxy.cfg
├── python-3-11/test.sh + test_script.py
├── python-3-12/test.sh + test_script.py
├── nodejs-20/test.sh + test_script.js
├── go-1-25/test.sh + test_program.go
├── postgresql/test.sh
├── valkey/test.sh
├── memcached/test.sh
├── python-3-14/test.sh + test_script.py
├── nodejs-24/test.sh + test_script.js
├── go-1-26/test.sh + test_program.go
├── rust/test.sh + test_program.rs
├── ruby-3-4/test.sh + test_script.rb
├── openjdk-21/test.sh + TestProgram.java
├── mariadb-10-11/test.sh
├── php/test.sh + test_script.php
└── tomcat-10/test.sh
```

Each image has 4 tests:

1. **Version check** — is the correct version installed?
2. **Basic execution** — does the core command work?
3. **Standard features** — do expected capabilities work?
4. **Real-world usage** — can it perform a practical task?

Tests use `set -euo pipefail`, exit 0 on success / 1 on failure, and work with both podman and docker (`TEST_ENGINE` env var).

---

## Image Naming

Hummingbird uses `{repository}:{stream}`, not `{directory-name}:latest`:

```
# python-3-13 directory → quay.io/hummingbird/python:3.13
# nodejs-22 directory   → quay.io/hummingbird/nodejs:22
# curl directory        → quay.io/hummingbird/curl:latest
```

To find the correct name from the [source repo](https://gitlab.com/redhat/hummingbird/containers):
```bash
grep "^repository:\|^stream:" images/{image-name}/properties.yml
```

---

## Adding a New Image Test

```bash
# 1. Create test directory
mkdir phase1-tests/<image-name>

# 2. Copy a template from a similar image
cp phase1-tests/curl/test.sh phase1-tests/<image-name>/

# 3. Edit test.sh — update IMAGE, test commands, assertions

# 4. Run locally
bash phase1-tests/<image-name>/test.sh

# 5. Add to run-all-tests.sh IMAGES array
```

Test plan templates for all 44 images are in `docs/test-plans/`.

---

## CI/CD

GitHub Actions runs on push/PR to main. Requires repo secrets:
- `QUAY_USERNAME` — quay.io username or robot account
- `QUAY_PASSWORD` — quay.io password or robot token

See [docs/QUAY-CREDENTIALS-SETUP.md](docs/QUAY-CREDENTIALS-SETUP.md) for setup instructions.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `unauthorized: access to the requested resource` | Run `podman login quay.io` or check GitHub secrets |
| `executable file not found in $PATH` | Specify command explicitly: `podman run image python3 --version` |
| `SSL certificate verification failed` | Use `-k` flag — minimal images may lack CA certs |
| Tests pass locally, fail in CI | Set `TEST_ENGINE=docker` — CI uses Docker |

---

## Additional Documentation

- [docs/test-details.md](docs/test-details.md) — what each image test covers
- [docs/PREREQUISITES.md](docs/PREREQUISITES.md) — environment setup
- [docs/QUAY-CREDENTIALS-SETUP.md](docs/QUAY-CREDENTIALS-SETUP.md) — registry credentials
- [docs/hummingbird-test-plan.md](docs/hummingbird-test-plan.md) — overall testing strategy
- [docs/test-plans/](docs/test-plans/) — test plan templates for all 44 images
