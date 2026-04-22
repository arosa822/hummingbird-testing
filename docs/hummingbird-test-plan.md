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

## Testing Phases

### Phase 1: Build Verification (CURRENT PHASE)
**Goal:** Verify we can successfully build images using Hummingbird components.

**Scope:**
- Can we build the image from source?
- Does the build complete without errors?
- Can we run the image successfully?
- Does basic functionality work?

**Selected Images for Phase 1 (5 images):**
1. [ ] **curl** - Simple utility, test HTTP requests
2. [ ] **jq** - JSON processor, test JSON parsing
3. [ ] **nginx** - Web server, test serving static content
4. [ ] **python-3-13** - Python runtime, test simple script execution
5. [ ] **nodejs-22** - Node.js runtime, test simple JS execution

**Success Criteria:**
- ✅ Image builds without errors
- ✅ Image runs successfully
- ✅ Basic functionality test passes

### Phase 2: Functional Testing (FUTURE)
- Comprehensive functionality tests
- Edge cases and error handling
- Documentation verification

### Phase 3: Security & Performance (FUTURE)
- Vulnerability scanning
- Performance benchmarks
- Production readiness assessment

---

## Phase 1 Testing Steps

For each selected image:

1. **Explore Image Structure**
   ```bash
   cd /workspace/artifacts/containers/images/<image-name>
   cat properties.yml          # View image configuration
   cat Containerfile.j2        # View build template
   cat test.sh                 # View existing tests
   ```

2. **Build the Image**
   ```bash
   cd /workspace/artifacts/containers

   # Build specific image (e.g., curl)
   ci/build_images.sh curl

   # Build specific distro/variant
   ci/build_images.sh curl/rawhide/default

   # Build with verbose output
   ci/build_images.sh --verbose curl
   ```

3. **Run Basic Functionality Test**
   ```bash
   # curl example
   podman run --rm quay.io/hummingbird/curl:latest https://example.com

   # jq example
   echo '{"name":"test"}' | podman run --rm -i quay.io/hummingbird/jq:latest '.name'

   # nginx example (requires setup)
   podman run --rm -p 8080:8080 quay.io/hummingbird/nginx:latest

   # python example
   podman run --rm quay.io/hummingbird/python-3-13:latest -c "print('Hello')"

   # nodejs example
   podman run --rm quay.io/hummingbird/nodejs-22:latest -e "console.log('Hello')"
   ```

4. **Run Built-in Tests** (if available)
   ```bash
   cd /workspace/artifacts/containers
   ci/run_tests_container.sh <image-name>
   ```

5. **Document Results**
   - Build success/failure
   - Build time
   - Any errors encountered
   - Basic functionality test results
   - Image size (check with `podman images`)

---

## Testing Tools Available

- **Makefile** - Build automation (`make <image-name>`)
- **ci/run_tests_container.sh** - Functional test runner
- **podman/docker** - Container runtime for testing

---

## Current Focus

**Phase 1 Priority Images:**
1. curl - Simplest utility
2. jq - Simple JSON tool
3. nginx - Common web server
4. python-3-13 - Popular language runtime
5. nodejs-22 - Popular language runtime

---

## Notes
- All images available at: `quay.io/hummingbird/<image>:latest`
- Builder variants available as: `<image>:latest-builder`
- Source code: `/workspace/repos/containers/images/<image-name>/`
