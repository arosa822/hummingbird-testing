# Phase 1 Tests: Build Verification

This directory contains Phase 1 build verification tests for 5 selected Hummingbird container images.

## Prerequisites

**Required:** Podman or Docker must be installed to run these tests.

See [PREREQUISITES.md](PREREQUISITES.md) for detailed installation instructions and requirements.

## Goal

Verify we can successfully build and run basic images using Hummingbird components.

## Selected Images

| Image | Category | Test Focus |
|-------|----------|------------|
| **curl** | Utility | HTTP/HTTPS requests |
| **jq** | Utility | JSON processing |
| **nginx** | Web Server | Static content serving |
| **python-3-13** | Language Runtime | Python code execution |
| **nodejs-22** | Language Runtime | JavaScript execution |

## Directory Structure

```
phase1-tests/
├── README.md                    # This file
├── curl/
│   ├── Dockerfile              # Example using curl as base
│   ├── test.sh                 # 4 automated tests
│   ├── test-curl.md            # Original test plan
│   └── README.md               # Test documentation
├── jq/
│   ├── Dockerfile
│   ├── test.sh                 # 4 automated tests
│   ├── test-jq.md
│   └── README.md
├── nginx/
│   ├── Dockerfile
│   ├── test.sh                 # 4 automated tests
│   ├── test-nginx.md
│   └── README.md
├── python-3-13/
│   ├── Dockerfile
│   ├── test.sh                 # 4 automated tests
│   ├── test_script.py          # Python test suite
│   ├── test-python-3-13.md
│   └── README.md
└── nodejs-22/
    ├── Dockerfile
    ├── test.sh                 # 4 automated tests
    ├── test_script.js          # JavaScript test suite
    ├── test-nodejs-22.md
    └── README.md
```

## Running Tests

### Individual Image Tests

```bash
# Navigate to specific image directory
cd curl/

# Make test script executable
chmod +x test.sh

# Run tests
./test.sh

# Or with docker
TEST_ENGINE=docker ./test.sh
```

### Run All Tests

```bash
# Run all Phase 1 tests
for dir in curl jq nginx python-3-13 nodejs-22; do
    echo "Testing $dir..."
    cd "$dir"
    chmod +x test.sh
    ./test.sh || echo "FAILED: $dir"
    cd ..
done
```

## Test Patterns

Each image test follows this pattern:

1. **Version Check** - Verify correct version is installed
2. **Basic Functionality** - Test core capability works
3. **Standard Features** - Validate expected features are available
4. **Real-World Usage** - Execute practical use case

## Success Criteria

For each image:
- ✅ All 4 tests pass
- ✅ No critical errors in output
- ✅ Exit code 0

## Workflow Integration

These tests are designed to be integrated into CI/CD workflows:

- **Exit codes**: 0 = success, 1 = failure
- **Standard output**: Clear pass/fail indicators
- **Cleanup**: Tests clean up after themselves (especially nginx)
- **Container engine agnostic**: Works with podman or docker

## Next Steps After Phase 1

Once these basic tests pass:

1. **Phase 2**: Comprehensive functional testing
2. **Phase 3**: Security scanning and performance testing
3. **Phase 4**: Integration testing with multi-container scenarios

## Notes

- Tests assume images are available at `quay.io/hummingbird/<image>:latest`
- nginx tests use port 8080 (non-privileged)
- Python and Node.js tests mount test scripts as read-only volumes
- All tests use `set -euo pipefail` for strict error handling
