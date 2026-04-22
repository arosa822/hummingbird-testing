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

44 images across 7 categories. **5 tested** in Phase 1.

### Utilities & Tools

| Image | Registry | Status |
|-------|----------|--------|
| curl | `quay.io/hummingbird/curl:latest` | Tested |
| jq | `quay.io/hummingbird/jq:latest` | Tested |
| git | `quay.io/hummingbird/git:latest` | |
| memcached | `quay.io/hummingbird/memcached:latest` | |
| minio | `quay.io/hummingbird/minio:latest` | |
| minio-client | `quay.io/hummingbird/minio-client:latest` | |

### Web Servers

| Image | Registry | Status |
|-------|----------|--------|
| nginx | `quay.io/hummingbird/nginx:latest` | Tested |
| caddy | `quay.io/hummingbird/caddy:latest` | |
| haproxy | `quay.io/hummingbird/haproxy:latest` | |
| httpd | `quay.io/hummingbird/httpd:latest` | |

### Language Runtimes

| Image | Registry | Status |
|-------|----------|--------|
| python-3-13 | `quay.io/hummingbird/python:3.13` | Tested |
| nodejs-22 | `quay.io/hummingbird/nodejs:22` | Tested |
| python-3-11 | `quay.io/hummingbird/python:3.11` | |
| python-3-12 | `quay.io/hummingbird/python:3.12` | |
| python-3-14 | `quay.io/hummingbird/python:3.14` | |
| nodejs-20 | `quay.io/hummingbird/nodejs:20` | |
| nodejs-24 | `quay.io/hummingbird/nodejs:24` | |
| nodejs-25 | `quay.io/hummingbird/nodejs:25` | |
| go-1-25 | `quay.io/hummingbird/go:1.25` | |
| go-1-26 | `quay.io/hummingbird/go:1.26` | |
| rust | `quay.io/hummingbird/rust:latest` | |
| php | `quay.io/hummingbird/php:latest` | |
| ruby-3-3 | `quay.io/hummingbird/ruby:3.3` | |
| ruby-3-4 | `quay.io/hummingbird/ruby:3.4` | |
| ruby-4-0 | `quay.io/hummingbird/ruby:4.0` | |
| openjdk-21 | `quay.io/hummingbird/openjdk:21` | |
| openjdk-25 | `quay.io/hummingbird/openjdk:25` | |

### .NET / ASP.NET

| Image | Registry | Status |
|-------|----------|--------|
| aspnet-runtime-8-0 | `quay.io/hummingbird/aspnet-runtime:8.0` | |
| aspnet-runtime-9-0 | `quay.io/hummingbird/aspnet-runtime:9.0` | |
| aspnet-runtime-10-0 | `quay.io/hummingbird/aspnet-runtime:10.0` | |
| dotnet-runtime-8-0 | `quay.io/hummingbird/dotnet-runtime:8.0` | |
| dotnet-runtime-9-0 | `quay.io/hummingbird/dotnet-runtime:9.0` | |
| dotnet-runtime-10-0 | `quay.io/hummingbird/dotnet-runtime:10.0` | |
| dotnet-sdk-8-0 | `quay.io/hummingbird/dotnet-sdk:8.0` | |
| dotnet-sdk-9-0 | `quay.io/hummingbird/dotnet-sdk:9.0` | |
| dotnet-sdk-10-0 | `quay.io/hummingbird/dotnet-sdk:10.0` | |

### Databases

| Image | Registry | Status |
|-------|----------|--------|
| mariadb-10-11 | `quay.io/hummingbird/mariadb:10.11` | |
| mariadb-11-8 | `quay.io/hummingbird/mariadb:11.8` | |
| postgresql | `quay.io/hummingbird/postgresql:latest` | |
| valkey | `quay.io/hummingbird/valkey:latest` | |

### Application Servers

| Image | Registry | Status |
|-------|----------|--------|
| tomcat-10 | `quay.io/hummingbird/tomcat:10` | |
| tomcat-11 | `quay.io/hummingbird/tomcat:11` | |

### Specialized

| Image | Registry | Status |
|-------|----------|--------|
| core-runtime | `quay.io/hummingbird/core-runtime:latest` | |
| bootc-os | `quay.io/hummingbird/bootc-os:latest` | |
| xcaddy | `quay.io/hummingbird/xcaddy:latest` | |

---

## Test Structure

```
phase1-tests/
├── run-all-tests.sh            # Run all 5 image tests
├── curl/
│   ├── test.sh                 # 4 smoke tests
│   └── README.md
├── jq/
│   ├── test.sh
│   └── README.md
├── nginx/
│   ├── test.sh
│   └── README.md
├── python-3-13/
│   ├── test.sh
│   ├── test_script.py
│   └── README.md
└── nodejs-22/
    ├── test.sh
    ├── test_script.js
    └── README.md
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

- [docs/PREREQUISITES.md](docs/PREREQUISITES.md) — environment setup
- [docs/QUAY-CREDENTIALS-SETUP.md](docs/QUAY-CREDENTIALS-SETUP.md) — registry credentials
- [docs/hummingbird-test-plan.md](docs/hummingbird-test-plan.md) — overall testing strategy
- [docs/test-plans/](docs/test-plans/) — test plan templates for all 44 images
