# Prerequisites for Running Phase 1 Tests

## Required Software

### Container Runtime (Required)
You must have one of the following installed:

- **Podman** (recommended)
  ```bash
  # Fedora/RHEL
  sudo dnf install podman

  # Ubuntu/Debian
  sudo apt install podman

  # macOS
  brew install podman
  ```

- **Docker**
  ```bash
  # Install via https://docs.docker.com/get-docker/
  ```

### Verify Installation

```bash
# Check podman
podman --version

# Or check docker
docker --version
```

## Network Requirements

Tests require internet access to:
- Pull images from `quay.io/hummingbird/*`
- Test HTTP/HTTPS endpoints (example.com, httpbin.org, google.com)

## Running Tests

### With Podman (default)
```bash
cd phase1-tests/curl
./test.sh
```

### With Docker
```bash
cd phase1-tests/curl
TEST_ENGINE=docker ./test.sh
```

### Run All Tests
```bash
cd phase1-tests
./run-all-tests.sh
```

## Alternative: Using Pre-built Images

If you have the Hummingbird containers repository cloned and want to build images locally:

```bash
# Build a specific image
cd /path/to/hummingbird/containers
ci/build_images.sh curl

# Then run tests
cd /path/to/hummingbird-testing/phase1-tests/curl
./test.sh
```

## CI/CD Integration

For GitHub Actions, GitLab CI, or other CI/CD platforms, ensure:
1. Container runtime is available (most CI runners have docker pre-installed)
2. Network access to quay.io is allowed
3. Set `TEST_ENGINE=docker` if using Docker-based runners

### GitHub Actions Example

See `workflow-example.yml` in this directory for a complete GitHub Actions workflow.

To use it:
```bash
# Create .github/workflows directory in your repo root
mkdir -p .github/workflows

# Copy the example
cp phase1-tests/workflow-example.yml .github/workflows/phase1-tests.yml

# Commit and push
git add .github/workflows/phase1-tests.yml
git commit -m "Add Phase 1 tests GitHub Actions workflow"
git push
```
