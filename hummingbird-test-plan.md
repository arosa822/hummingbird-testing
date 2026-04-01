# Hummingbird Container Images - Test Plan

## Project Overview
Project Hummingbird builds minimal, hardened, secure container images with reduced attack surface, targeting near-zero vulnerabilities. All images support amd64 and arm64 architectures.

**Repository:** https://gitlab.com/redhat/hummingbird/containers
**Registry:** https://quay.io/organization/hummingbird

---

## Image Inventory (44 Images)

### Base Runtime Images (1)
- [ ] **core-runtime** - Minimal runtime environment with essential libraries (glibc, etc.)

### Language Runtimes

#### .NET/ASP.NET (9 images)
- [ ] **aspnet-runtime-8-0** - ASP.NET Core 8.0 runtime
- [ ] **aspnet-runtime-9-0** - ASP.NET Core 9.0 runtime
- [ ] **aspnet-runtime-10-0** - ASP.NET Core 10.0 runtime
- [ ] **dotnet-runtime-8-0** - .NET 8.0 runtime
- [ ] **dotnet-runtime-9-0** - .NET 9.0 runtime
- [ ] **dotnet-runtime-10-0** - .NET 10.0 runtime
- [ ] **dotnet-sdk-8-0** - .NET SDK 8.0
- [ ] **dotnet-sdk-9-0** - .NET SDK 9.0
- [ ] **dotnet-sdk-10-0** - .NET SDK 10.0

#### Go (2 images)
- [ ] **go-1-25** - Go 1.25
- [ ] **go-1-26** - Go 1.26

#### Java (2 images)
- [ ] **openjdk-21** - OpenJDK 21
- [ ] **openjdk-25** - OpenJDK 25

#### Node.js (4 images)
- [ ] **nodejs-20** - Node.js 20
- [ ] **nodejs-22** - Node.js 22
- [ ] **nodejs-24** - Node.js 24
- [ ] **nodejs-25** - Node.js 25

#### PHP (1 image)
- [ ] **php** - PHP runtime

#### Python (4 images)
- [ ] **python-3-11** - Python 3.11
- [ ] **python-3-12** - Python 3.12
- [ ] **python-3-13** - Python 3.13
- [ ] **python-3-14** - Python 3.14

#### Ruby (3 images)
- [ ] **ruby-3-3** - Ruby 3.3
- [ ] **ruby-3-4** - Ruby 3.4
- [ ] **ruby-4-0** - Ruby 4.0

#### Rust (1 image)
- [ ] **rust** - Rust toolchain

### Databases (4 images)
- [ ] **mariadb-10-11** - MariaDB 10.11
- [ ] **mariadb-11-8** - MariaDB 11.8
- [ ] **postgresql** - PostgreSQL database
- [ ] **valkey** - Valkey (Redis fork)

### Web Servers (4 images)
- [ ] **caddy** - Caddy web server
- [ ] **haproxy** - HAProxy load balancer
- [ ] **httpd** - Apache HTTP Server
- [ ] **nginx** - Nginx web server

### Application Servers (2 images)
- [ ] **tomcat-10** - Apache Tomcat 10
- [ ] **tomcat-11** - Apache Tomcat 11

### Utilities & Tools (6 images)
- [ ] **curl** - curl command-line tool
- [ ] **git** - Git version control
- [ ] **jq** - JSON processor
- [ ] **memcached** - Memcached caching system
- [ ] **minio** - MinIO object storage
- [ ] **minio-client** - MinIO client (mc)

### Specialized Images (2 images)
- [ ] **bootc-os** - Bootable container OS
- [ ] **xcaddy** - Caddy builder with plugins

---

## Test Categories

### 1. Functional Tests
Test that each image works as expected for its primary purpose.

### 2. Security Tests
- Vulnerability scanning (Syft/Grype)
- CVE count verification
- Non-root user verification
- Attack surface analysis

### 3. Compatibility Tests
- Architecture support (amd64/arm64)
- Variant testing (default vs builder)
- Multi-stage build patterns

### 4. Performance Tests
- Image size verification
- Startup time
- Resource usage

### 5. Integration Tests
- Multi-container scenarios
- Volume mounting
- Networking

---

## Testing Tools Available

- **ci/run_tests_container.sh** - Functional test runner
- **ci/syft-hummingbird.sh** - SBOM generation
- **ci/grype-hummingbird.sh** - Vulnerability scanning
- **Makefile** - Build and test automation
- **report.json / report.md** - Existing vulnerability reports

---

## Next Steps

1. [ ] Define test priorities (which images to test first)
2. [ ] Determine test scope (functional, security, or both)
3. [ ] Identify specific test scenarios for each image category
4. [ ] Create test execution plan
5. [ ] Define success criteria

---

## Notes
- All images available at: `quay.io/hummingbird/<image>:latest`
- Builder variants available as: `<image>:latest-builder`
- Source code: `/workspace/repos/containers/images/<image-name>/`
