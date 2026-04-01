# Hummingbird Container Images - Testing Framework

## Session Overview

This directory contains a comprehensive testing framework created for the **Project Hummingbird** container images. The goal of this session was to establish a structured approach for testing all 44 container images in the Hummingbird project.

**Project Hummingbird** builds minimal, hardened, secure container images with a significantly reduced attack surface, targeting near-zero vulnerabilities. All images support amd64 and arm64 architectures.

- **Repository:** https://gitlab.com/redhat/hummingbird/containers
- **Registry:** https://quay.io/organization/hummingbird
- **Local Clone:** `/workspace/repos/containers/` (if cloned)

---

## Purpose & Objectives

### Main Goals
1. **Inventory all images** - Catalog all 44 container images in the Hummingbird project
2. **Create test templates** - Develop standardized test plans for each image
3. **Enable systematic testing** - Provide a framework for running functional and security tests
4. **Support workflow creation** - Build foundation for automated testing workflows

### Testing Focus Areas
- **Functional Testing** - Verify each image works for its primary purpose
- **Security Testing** - Vulnerability scanning, CVE analysis, non-root verification
- **Compatibility Testing** - Architecture support (amd64/arm64), variant testing
- **Performance Testing** - Image size, startup time, resource usage
- **Integration Testing** - Multi-container scenarios, volume mounting, networking

---

## Directory Structure

```
hummingbird-testing/
├── README.md                          # This file - overview and usage guide
├── images-list.md                     # Complete inventory of all 44 images
├── hummingbird-test-plan.md          # High-level test plan and strategy
└── test-<image-name>.md (44 files)   # Individual test plans for each image
```

### File Descriptions

**README.md**
- Overview of the testing framework
- Usage instructions
- Session objectives

**images-list.md**
- Complete catalog of all 44 images
- Organized by category (languages, databases, web servers, utilities, etc.)
- Quick reference for image names

**hummingbird-test-plan.md**
- Strategic test plan document
- Test categories and methodologies
- Testing tools available
- Next steps and priorities

**test-<image-name>.md (44 files)**
- Individual test plan for each specific image
- Image description and primary utility
- Comprehensive test checklists
- Test command templates
- Results tracking section

---

## How to Use This Framework

### 1. Review the Inventory
Start with `images-list.md` to see all available images organized by category.

### 2. Select Images to Test
Choose which images to prioritize based on:
- Usage frequency (e.g., python, nginx, postgresql)
- Critical infrastructure components
- New or recently updated images

### 3. Use Individual Test Plans
Each `test-<image-name>.md` file contains:
- **Description** - What the image does
- **Primary Utility** - Main purpose/command
- **Test Checklist** - Standardized tests to run
- **Test Commands** - Command templates ready to customize
- **Results Section** - Track test outcomes

### 4. Execute Tests
Run tests using the Hummingbird project's built-in tools:

```bash
# Clone the repository (if not already done)
cd /workspace/repos
git clone https://gitlab.com/redhat/hummingbird/containers.git

# Run functional tests for a specific image
cd containers
./ci/run_tests_container.sh <image-name>

# Run vulnerability scan
./ci/grype-hummingbird.sh quay.io/hummingbird/<image-name>:latest

# Run all checks (comprehensive)
make check
```

### 5. Document Results
Update each test file with:
- Test execution date
- Tester name
- Status (Not Started / In Progress / Passed / Failed)
- Findings and notes

---

## Image Categories

### Base Runtime (1)
- core-runtime

### Language Runtimes (23)
- .NET/ASP.NET: 9 images (versions 8.0, 9.0, 10.0)
- Go: 2 images (1.25, 1.26)
- Java: 2 images (OpenJDK 21, 25)
- Node.js: 4 images (20, 22, 24, 25)
- PHP: 1 image
- Python: 4 images (3.11, 3.12, 3.13, 3.14)
- Ruby: 3 images (3.3, 3.4, 4.0)
- Rust: 1 image

### Databases (4)
- MariaDB: 2 versions (10.11, 11.8)
- PostgreSQL
- Valkey (Redis fork)

### Web Servers (4)
- Caddy
- HAProxy
- httpd (Apache)
- nginx

### Application Servers (2)
- Tomcat 10
- Tomcat 11

### Utilities & Tools (6)
- curl
- git
- jq
- memcached
- minio
- minio-client

### Specialized (2)
- bootc-os
- xcaddy

---

## Available Testing Tools

From the Hummingbird repository (`/workspace/repos/containers/`):

| Tool | Purpose | Command |
|------|---------|---------|
| **run_tests_container.sh** | Run functional tests | `./ci/run_tests_container.sh <image>` |
| **syft-hummingbird.sh** | Generate SBOM | `./ci/syft-hummingbird.sh <image>` |
| **grype-hummingbird.sh** | Vulnerability scanning | `./ci/grype-hummingbird.sh <image>` |
| **Makefile** | Build automation | `make check`, `make all` |
| **report.json/md** | Existing reports | Pre-generated vulnerability reports |

---

## Next Steps

### Immediate Actions
1. **Prioritize images** - Decide which images to test first
2. **Customize test commands** - Fill in specific test scenarios for each image
3. **Run initial tests** - Execute tests on high-priority images
4. **Document findings** - Record results in individual test files

### Future Enhancements
1. **Create workflows** - Automate test execution (CI/CD)
2. **Add specific tests** - Develop detailed test cases per image category
3. **Integration tests** - Build multi-container test scenarios
4. **Performance benchmarks** - Establish baseline metrics
5. **Continuous testing** - Regular vulnerability scanning and updates

---

## Example: Testing the curl Image

1. **Open test file:** `test-curl.md`
2. **Review checklist:** See what needs to be tested
3. **Pull image:**
   ```bash
   podman pull quay.io/hummingbird/curl:latest
   ```
4. **Run functional test:**
   ```bash
   podman run quay.io/hummingbird/curl -v https://example.com
   ```
5. **Run security scan:**
   ```bash
   cd /workspace/repos/containers
   ./ci/grype-hummingbird.sh quay.io/hummingbird/curl:latest
   ```
6. **Document results:** Update `test-curl.md` with findings

---

## Resources

- **Hummingbird Documentation:** https://hummingbird-project.io/
- **Quay Registry:** https://quay.io/organization/hummingbird
- **GitLab Repository:** https://gitlab.com/redhat/hummingbird/containers
- **Local Repository:** `/workspace/repos/containers/`

---

## Session Summary

**Created:** April 1, 2026
**Purpose:** Establish comprehensive testing framework for Hummingbird container images
**Deliverables:**
- ✅ Complete image inventory (44 images)
- ✅ Individual test plans for all 44 images
- ✅ Standardized test checklists
- ✅ Test command templates
- ✅ Results tracking framework

**Status:** Framework ready for test execution
**Next Phase:** Begin systematic testing of prioritized images

---

## Contact & Contributions

This testing framework is designed to be collaborative and extensible. As tests are executed and refined, update the individual test files with:
- More specific test commands
- Additional test scenarios
- Integration test examples
- Performance benchmarks
- Common issues and solutions

Good luck with your testing! 🚀
