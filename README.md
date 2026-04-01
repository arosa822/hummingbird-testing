# Hummingbird Container Images - Testing Framework

**Automated testing framework for Red Hat Hummingbird minimal container images**

[![Phase 1 Tests](https://github.com/arosa822/hummingbird-testing/actions/workflows/phase1-tests.yml/badge.svg)](https://github.com/arosa822/hummingbird-testing/actions)

**Project Hummingbird** builds minimal, hardened, secure container images with a significantly reduced attack surface, targeting near-zero vulnerabilities. All images support amd64 and arm64 architectures.

- **Source Repository:** https://gitlab.com/redhat/hummingbird/containers
- **Registry:** https://quay.io/organization/hummingbird
- **Documentation:** https://hummingbird-project.io/

---

## Quick Start

### Run Tests Locally

```bash
# Clone this repository
git clone https://github.com/arosa822/hummingbird-testing
cd hummingbird-testing

# Login to quay.io
podman login quay.io

# Run a single test
cd phase1-tests/curl
./test.sh

# Run all Phase 1 tests
cd phase1-tests
./run-all-tests.sh
```

### View Test Results

**GitHub Actions:** https://github.com/arosa822/hummingbird-testing/actions

```bash
# Using the test results script (requires gh CLI)
python3 scripts/get-latest-test-run.py
```

---

## Current Status

### Phase 1: Build Verification ✅

**Goal:** Verify we can successfully build and run Hummingbird container images

**Status:** 5/5 tests passing

| Image | Status | Tests | Purpose |
|-------|--------|-------|---------|
| curl | ✅ Passing | 4/4 | HTTP/HTTPS requests |
| jq | ✅ Passing | 4/4 | JSON processing |
| nginx | ✅ Passing | 4/4 | Web server |
| python-3-13 | ✅ Passing | 4/4 | Python runtime |
| nodejs-22 | ✅ Passing | 4/4 | Node.js runtime |

**Test Coverage:** 5 of 44 images (11%)

---

## Testing Approach

### Phase 1: Build Verification (Current)

**Focus:** Can we build and run these images?

Each image has 4 automated tests:
1. **Version Check** - Is the software installed correctly?
2. **Basic Execution** - Can we run basic commands?
3. **Standard Features** - Do expected features work?
4. **Real-World Usage** - Can we perform practical tasks?

**Test Structure:**
- Automated bash scripts (`test.sh`)
- Clear pass/fail output with ✓/✗ indicators
- Exit codes for CI/CD integration (0=success, 1=failure)
- Works with both podman and docker

### Future Phases

**Phase 2: Functional Testing** (Planned)
- Comprehensive functionality validation
- Edge cases and error handling
- Integration scenarios

**Phase 3: Security & Performance** (Planned)
- Vulnerability scanning
- Performance benchmarks
- Production readiness assessment

---

## Directory Structure

```
hummingbird-testing/
├── README.md                      # This file
├── SESSION-SUMMARY.md             # Session history and context
├── HANDOFF-NOTES.md               # Colleague review guide
├── hummingbird-test-plan.md       # Overall testing strategy
├── images-list.md                 # All 44 available images
├── test-*.md (44 files)           # Individual test plan templates
│
├── phase1-tests/                  # ⭐ Phase 1 automated tests
│   ├── README.md                  # Phase 1 overview
│   ├── PREREQUISITES.md           # Setup requirements
│   ├── QUAY-CREDENTIALS-SETUP.md  # GitHub Secrets guide
│   ├── FIX-SUMMARY.md             # Debugging documentation
│   ├── workflow-example.yml       # GitHub Actions template
│   ├── run-all-tests.sh           # Master test runner
│   │
│   ├── curl/                      # curl test suite
│   │   ├── test.sh                # 4 automated tests
│   │   ├── Dockerfile             # Usage example
│   │   ├── README.md              # Test documentation
│   │   └── test-curl.md           # Full test plan
│   │
│   ├── jq/                        # jq test suite
│   ├── nginx/                     # nginx test suite
│   ├── python-3-13/               # Python test suite
│   │   └── test_script.py         # Python-specific tests
│   └── nodejs-22/                 # Node.js test suite
│       └── test_script.js         # JavaScript-specific tests
│
└── scripts/
    └── get-latest-test-run.py     # Fetch GitHub Actions results
```

---

## Usage

### Prerequisites

**Required:**
- Container runtime: podman or docker
- Access to quay.io/hummingbird/* images
- Network access for test endpoints

**For local testing:**
```bash
# Login to quay.io
podman login quay.io
# (Enter your credentials)
```

**For GitHub Actions:**
- Configure `QUAY_USERNAME` and `QUAY_PASSWORD` as repository secrets
- See `phase1-tests/QUAY-CREDENTIALS-SETUP.md` for detailed instructions

### Running Tests

#### Single Image Test

```bash
cd phase1-tests/curl
./test.sh

# Example output:
# ==================================
# Phase 1: curl Image Tests
# ==================================
#
# [TEST 1] Basic HTTP GET to example.com
# ✓ PASSED - Got HTTP 200 response
#
# [TEST 2] Verify curl version command works
# ✓ PASSED - curl version detected
# ...
```

#### All Phase 1 Tests

```bash
cd phase1-tests
./run-all-tests.sh

# Summary output:
# ========================================
# Phase 1 Test Summary
# ========================================
# Total Images: 5
# Passed: 5
# Failed: 0
#
# ✅ Phase 1 tests PASSED - All images verified!
```

#### With Docker Instead of Podman

```bash
TEST_ENGINE=docker ./test.sh
```

#### Check Latest GitHub Actions Results

```bash
# View summary
python3 scripts/get-latest-test-run.py

# View summary with logs for failed jobs
python3 scripts/get-latest-test-run.py --logs
```

---

## Example: Testing curl

```bash
# Navigate to curl test directory
cd phase1-tests/curl

# Review what will be tested
cat README.md

# Run the tests
./test.sh

# Expected output:
# ==================================
# Phase 1: curl Image Tests
# ==================================
#
# [TEST 1] Basic HTTP GET to example.com
# Command: podman run --rm quay.io/hummingbird/curl:latest http://example.com
# ✓ PASSED - Got HTTP 200 response
#
# [TEST 2] Verify curl version command works
# Command: podman run --rm quay.io/hummingbird/curl:latest --version
# Output: curl 8.x.x ...
# ✓ PASSED - curl version detected
#
# [TEST 3] Verify HTTPS/TLS support
# Command: podman run --rm quay.io/hummingbird/curl:latest -k -s https://www.google.com
# ✓ PASSED - HTTPS connection successful (HTTP 200)
#
# [TEST 4] Fetch JSON from API endpoint
# Command: podman run --rm quay.io/hummingbird/curl:latest -k -s https://httpbin.org/json
# ✓ PASSED - Successfully fetched JSON response
#
# ==================================
# All curl tests PASSED!
# ==================================
```

---

## Available Images (44 Total)

### Base Runtime (1)
- core-runtime

### Language Runtimes (23)
**Status:** 2 of 23 tested (python-3-13, nodejs-22)

- **.NET/ASP.NET** (9): aspnet-runtime-{8,9,10}-0, dotnet-runtime-{8,9,10}-0, dotnet-sdk-{8,9,10}-0
- **Go** (2): go-1-25, go-1-26
- **Java** (2): openjdk-21, openjdk-25
- **Node.js** (4): nodejs-20, nodejs-22 ✅, nodejs-24, nodejs-25
- **PHP** (1): php
- **Python** (4): python-3-11, python-3-12, python-3-13 ✅, python-3-14
- **Ruby** (3): ruby-3-3, ruby-3-4, ruby-4-0
- **Rust** (1): rust

### Databases (4)
**Status:** 0 of 4 tested

- mariadb-10-11, mariadb-11-8
- postgresql
- valkey (Redis fork)

### Web Servers (4)
**Status:** 1 of 4 tested (nginx)

- caddy
- haproxy
- httpd (Apache)
- nginx ✅

### Application Servers (2)
**Status:** 0 of 2 tested

- tomcat-10, tomcat-11

### Utilities & Tools (6)
**Status:** 2 of 6 tested (curl, jq)

- curl ✅
- git
- jq ✅
- memcached
- minio
- minio-client

### Specialized (2)
**Status:** 0 of 2 tested

- bootc-os
- xcaddy

---

## GitHub Actions Integration

### Workflow Setup

Copy the workflow template to enable automated testing:

```bash
# Copy the example workflow
mkdir -p .github/workflows
cp phase1-tests/workflow-example.yml .github/workflows/phase1-tests.yml

# Commit and push
git add .github/workflows/phase1-tests.yml
git commit -m "Enable Phase 1 tests in GitHub Actions"
git push
```

### Configure Secrets

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add secrets:
   - `QUAY_USERNAME` - Your quay.io username or robot account
   - `QUAY_PASSWORD` - Your quay.io password or robot token

See `phase1-tests/QUAY-CREDENTIALS-SETUP.md` for detailed instructions.

### Workflow Features

- **Parallel execution** - All 5 tests run simultaneously
- **Automatic authentication** - Logs into quay.io before tests
- **Clear results** - Each test job shows pass/fail
- **Triggers:**
  - On push to main
  - On pull request
  - Manual workflow dispatch

---

## Key Learnings

### 1. Image Naming Pattern

Hummingbird uses `{repository}:{stream}`, not `{directory-name}:latest`

```yaml
# Example: python-3-13/properties.yml
repository: python    # NOT "python-3-13"
stream: "3.13"

# Correct image: quay.io/hummingbird/python:3.13
# Wrong: quay.io/hummingbird/python-3-13:latest
```

**To find correct image name:**
```bash
cd /path/to/containers/images/{image-name}
grep "^repository:\|^stream:" properties.yml
# Image: quay.io/hummingbird/{repository}:{stream}
```

### 2. Minimal Images Considerations

- **No CA certificates** - Use `-k` flag for HTTPS testing
- **Different entrypoints** - Some require explicit command (e.g., `python3`)
- **Smaller attack surface** - Security-focused, may lack convenience features

### 3. Test Design Principles

- **Simple first** - Version check before complex scenarios
- **Clear output** - ✓/✗ indicators for easy scanning
- **Exit codes** - 0=success, 1=failure for automation
- **Container engine agnostic** - Works with podman or docker

---

## Adding More Images

### Pattern to Follow

Use existing tests as templates:

```bash
# 1. Create new test directory
mkdir phase1-tests/new-image

# 2. Copy template from similar image
cp phase1-tests/curl/test.sh phase1-tests/new-image/
cp phase1-tests/curl/README.md phase1-tests/new-image/
cp phase1-tests/curl/Dockerfile phase1-tests/new-image/

# 3. Update for new image
# - Change IMAGE variable
# - Adjust test commands
# - Update documentation

# 4. Test locally
cd phase1-tests/new-image
./test.sh

# 5. Add to run-all-tests.sh
# Edit IMAGES array to include "new-image"
```

### Recommended Next Images

**Easy wins (similar to existing):**
- git (utility, like curl)
- nodejs-20, nodejs-24 (same pattern as nodejs-22)
- python-3-11, python-3-12, python-3-14 (same pattern as python-3-13)

**Medium complexity:**
- postgresql (database, needs initialization)
- httpd (web server, like nginx)

**More complex:**
- tomcat (application server, needs app deployment)
- mariadb (database with complex setup)

---

## Troubleshooting

### Common Issues

**"unauthorized: access to the requested resource is not authorized"**
- Ensure you're logged in: `podman login quay.io`
- For GitHub Actions: Check `QUAY_USERNAME` and `QUAY_PASSWORD` secrets

**"executable file not found in $PATH"**
- Image may not have default entrypoint
- Explicitly specify command: `podman run image python3 --version`

**SSL certificate verification failed**
- Minimal images may lack CA certificates
- Use `-k` flag for testing: `curl -k https://...`

**Tests pass locally but fail in CI**
- Check container engine: Set `TEST_ENGINE=docker` in GitHub Actions
- Verify image names match quay.io repository

### Getting Help

1. **Check documentation:**
   - `phase1-tests/README.md` - Phase 1 overview
   - `phase1-tests/PREREQUISITES.md` - Setup guide
   - `phase1-tests/FIX-SUMMARY.md` - Common issues and solutions

2. **Review test results:**
   ```bash
   python3 scripts/get-latest-test-run.py --logs
   ```

3. **Open an issue:**
   https://github.com/arosa822/hummingbird-testing/issues

---

## Contributing

### Adding Tests

1. Follow existing patterns in `phase1-tests/`
2. Include all 4 test components:
   - Version check
   - Basic execution
   - Feature validation
   - Real-world usage
3. Document what each test does in README.md
4. Test locally before committing

### Documentation

- Keep README files up to date
- Document any issues and solutions
- Add examples for complex scenarios
- Update this README when adding new phases

### Pull Requests

- Run tests locally first
- Include clear description of changes
- Update documentation as needed
- Follow existing code style

---

## Resources

### Project Links

- **This Repository:** https://github.com/arosa822/hummingbird-testing
- **Hummingbird Source:** https://gitlab.com/redhat/hummingbird/containers
- **Hummingbird Registry:** https://quay.io/organization/hummingbird
- **Hummingbird Docs:** https://hummingbird-project.io/

### Documentation

- **Phase 1 Tests:** `phase1-tests/README.md`
- **Session Summary:** `SESSION-SUMMARY.md`
- **Handoff Notes:** `HANDOFF-NOTES.md`
- **Fix Summary:** `phase1-tests/FIX-SUMMARY.md`

### Tools

- **GitHub CLI:** https://cli.github.com/
- **Podman:** https://podman.io/
- **Docker:** https://www.docker.com/

---

## Project Timeline

**Created:** April 1, 2026

**Phase 1: Build Verification**
- ✅ Test framework created
- ✅ 5 images tested and passing
- ✅ GitHub Actions integration
- ✅ Documentation complete
- **Status:** Production ready

**Phase 2: Functional Testing** (Planned)
- Comprehensive test scenarios
- Edge case handling
- Integration testing

**Phase 3: Security & Performance** (Planned)
- Vulnerability scanning
- Performance benchmarking
- Production readiness checks

---

## License

This testing framework is designed for testing Red Hat Hummingbird container images.

For Hummingbird project license information, see: https://gitlab.com/redhat/hummingbird/containers

---

## Acknowledgments

Built with the goal of ensuring Hummingbird container images are reliable, secure, and production-ready.

**Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>**

---

*Last Updated: April 1, 2026*
*Status: Phase 1 Complete - 5/5 tests passing ✅*
