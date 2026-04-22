# Test Plan: xcaddy

## Image Information
- **Image Name:** xcaddy
- **Registry:** quay.io/hummingbird/xcaddy
- **Variants:** 
  - `latest` - Default distroless variant
  - `latest-builder` - Builder variant with package manager

## Description
xcaddy custom Caddy builder for creating Caddy binaries with additional plugins and modules.

## Primary Utility
xcaddy command for building custom Caddy servers

## Test Checklist

### Basic Functionality
- [ ] Image pulls successfully
- [ ] Container starts without errors
- [ ] Primary utility/command works
- [ ] Container runs as non-root user (UID 65532)
- [ ] Image supports amd64 architecture
- [ ] Image supports arm64 architecture

### Security Tests
- [ ] Vulnerability scan shows acceptable CVE count
- [ ] No critical vulnerabilities present
- [ ] Distroless variant has no package manager
- [ ] Builder variant has dnf package manager

### Variant Tests
- [ ] Default variant works for runtime scenarios
- [ ] Builder variant can install additional packages
- [ ] Multi-stage build pattern works (if applicable)

## Test Commands

### Pull and Inspect
```bash
podman pull quay.io/hummingbird/xcaddy:latest
podman inspect quay.io/hummingbird/xcaddy:latest
```

### Run Basic Test
```bash
# Add specific test command here
```

### Security Scan
```bash
./ci/grype-hummingbird.sh quay.io/hummingbird/xcaddy:latest
```

## Notes
- 

## Test Results
- **Date:** 
- **Tester:** 
- **Status:** ⬜ Not Started | 🟡 In Progress | ✅ Passed | ❌ Failed
- **Findings:**
