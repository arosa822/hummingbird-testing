# Image Onboarding Workflow

## Overview

This workflow systematically onboards Hummingbird container images into the testing framework in batches of 5 images at a time.

## Workflow Phases

```
1. SELECT     → Pick 5 images (by popularity/exposure)
2. GENERATE   → Create test folders with basic tests
3. EXECUTE    → Run tests and validate
4. ITERATE    → Fix test infrastructure issues
5. ANALYZE    → Identify image vs test problems
6. INTEGRATE  → Create integration tests
7. COMMIT     → Commit batch of 5 images
8. REPEAT     → Move to next batch
```

---

## Phase 1: SELECT (Image Selection)

### Selection Criteria (Priority Order)

1. **Popularity/Exposure**
   - Most commonly used in production
   - Frequently referenced in documentation
   - High download counts (if metrics available)

2. **Category Balance**
   - Mix of languages, utilities, databases
   - Avoid onboarding all of one type at once
   - Ensure diverse testing scenarios

3. **Complexity Level**
   - Start with simpler images
   - Progress to more complex (databases, app servers)
   - Build expertise gradually

4. **Dependency Relationships**
   - Images that depend on each other
   - Base images before derived images
   - Common runtime before specific versions

### Recommended Batches

**Batch 1 (COMPLETED):** ✅
- curl, jq, nginx, python-3-13, nodejs-22

**Batch 2 (Utilities):**
- git (version control - very popular)
- httpd (Apache - alternative to nginx)
- memcached (caching - common utility)
- postgresql (database - widely used)
- valkey (Redis alternative - popular)

**Batch 3 (More Languages):**
- python-3-12 (previous Python version)
- nodejs-20 (LTS version)
- go-1-26 (popular compiled language)
- ruby-3-4 (latest Ruby)
- rust (systems programming)

**Batch 4 (Databases & App Servers):**
- mariadb-11-8 (latest MariaDB)
- tomcat-11 (latest Tomcat)
- php (web language)
- openjdk-21 (LTS Java)
- caddy (modern web server)

**Batch 5 (.NET Stack):**
- dotnet-sdk-10-0
- dotnet-runtime-10-0
- aspnet-runtime-10-0
- dotnet-sdk-9-0
- dotnet-runtime-9-0

### Selection Command

```bash
# Review available images
cat images-list.md

# Check properties to understand the image
cd /workspace/artifacts/containers/images/git
cat properties.yml
cat README.md

# Determine correct image name
grep "^repository:\|^stream:" properties.yml
```

---

## Phase 2: GENERATE (Create Test Structure)

### For Each Image in Batch

#### Step 1: Determine Correct Image Name

```bash
cd /workspace/artifacts/containers/images/<image-name>
grep "^repository:\|^stream:" properties.yml

# Example output:
# repository: git
# stream: "2"

# Correct image: quay.io/hummingbird/git:2
# NOT: quay.io/hummingbird/git:latest (unless stream matches)
```

#### Step 2: Create Test Directory

```bash
cd /workspace/artifacts/hummingbird-testing/phase1-tests
mkdir -p <image-name>
cd <image-name>
```

#### Step 3: Copy Template from Similar Image

**For Utilities (like curl, jq):**
```bash
cp ../curl/test.sh .
cp ../curl/Dockerfile .
cp ../curl/README.md .
```

**For Language Runtimes (like python, nodejs):**
```bash
cp ../python-3-13/test.sh .
cp ../python-3-13/Dockerfile .
cp ../python-3-13/README.md .
cp ../python-3-13/test_script.py .  # If applicable
```

**For Web Servers (like nginx):**
```bash
cp ../nginx/test.sh .
cp ../nginx/Dockerfile .
cp ../nginx/README.md .
```

#### Step 4: Customize Tests

Edit `test.sh` to:
1. Update `IMAGE` variable with correct name
2. Adjust test commands for the specific image
3. Update test descriptions
4. Modify version check patterns

**Key Variables to Update:**
```bash
IMAGE="quay.io/hummingbird/<repository>:<stream>"
```

**Common Test Pattern:**
```bash
# Test 1: Version check
# Test 2: Basic execution
# Test 3: Common feature
# Test 4: Real-world usage
```

#### Step 5: Update Documentation

Edit `README.md` to describe:
- What the image does
- What each test validates
- Expected output
- Real-world use cases

---

## Phase 3: EXECUTE (Run Tests)

### Run Tests Locally

```bash
cd phase1-tests/<image-name>

# Make executable
chmod +x test.sh

# Run the test
./test.sh

# Or with docker
TEST_ENGINE=docker ./test.sh
```

### Check Results

**Success Case:**
```
==================================
All <image> tests PASSED!
==================================
```

**Failure Case:**
```
✗ FAILED - <error message>
```

### Document Initial Results

Create a checklist:
```
Batch 2 Initial Results:
- git: ✓ PASS
- httpd: ✗ FAIL (SSL cert issue)
- memcached: ✓ PASS
- postgresql: ✗ FAIL (initialization required)
- valkey: ✓ PASS
```

---

## Phase 4: ITERATE (Fix Test Infrastructure)

### Identify Test Infrastructure Issues

**Test infrastructure issues** are problems with HOW we're testing, not the image itself.

#### Common Test Infrastructure Issues:

1. **Wrong Image Name**
   - **Symptom:** "unauthorized" or "image not found"
   - **Fix:** Check `properties.yml` for correct `repository:stream`
   - **Example:** Using `python-3-13:latest` instead of `python:3.13`

2. **Missing Entrypoint Specification**
   - **Symptom:** "executable file not found in $PATH"
   - **Fix:** Add explicit command (e.g., `python3`, `node`)
   - **Example:** Python requires `python3 --version` not just `--version`

3. **SSL Certificate Issues**
   - **Symptom:** "SSL certificate problem" or exit code 60
   - **Fix:** Add `-k` flag for curl, or use HTTP instead of HTTPS
   - **Example:** curl needs `-k` for HTTPS in minimal images

4. **Port Conflicts**
   - **Symptom:** "address already in use"
   - **Fix:** Use unique ports or ensure cleanup
   - **Example:** Multiple nginx tests on same port

5. **Timing Issues**
   - **Symptom:** Intermittent failures, "connection refused"
   - **Fix:** Add sleep/retry logic for service startup
   - **Example:** Wait for database to initialize

6. **Permission Issues**
   - **Symptom:** "permission denied"
   - **Fix:** Check user (1001) or use USER 0 temporarily
   - **Example:** Writing to /app requires correct ownership

### Fix Infrastructure Issues

For each identified infrastructure issue:

1. **Update test script** with fix
2. **Re-run test** to verify
3. **Document the fix** in comments
4. **Check if other images need same fix**

### Example Fixes

**Fix 1: Python entrypoint issue**
```bash
# Before (broken)
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} --version)

# After (fixed)
VERSION_OUTPUT=$(${TEST_ENGINE} run --rm ${IMAGE} python3 --version)
```

**Fix 2: curl SSL issue**
```bash
# Before (broken)
curl -s https://example.com

# After (fixed)
curl -k -s https://example.com  # Skip cert verification
```

**Fix 3: Image name issue**
```bash
# Before (broken)
IMAGE="quay.io/hummingbird/git:latest"

# After (fixed - from properties.yml)
IMAGE="quay.io/hummingbird/git:2"
```

---

## Phase 5: ANALYZE (Image vs Test Issues)

### Decision Tree

After infrastructure fixes, if tests still fail:

```
Test fails
    ↓
Is it a test infrastructure issue?
    ├─ YES → Go to Phase 4 (Iterate)
    └─ NO ↓
        Is it an image issue?
            ├─ YES → Document and report
            └─ NO → Needs investigation
```

### Categorize Failures

#### ✅ Test Infrastructure Issue (We Fix)
- Wrong image name/tag
- Missing command specification
- SSL certificate handling
- Timing/race conditions
- Port conflicts
- Insufficient permissions in test

**Action:** Fix the test and continue

#### ⚠️ Image Issue (Report & Document)
- Image doesn't exist in registry
- Image is corrupted
- Required binary missing from image
- Image crashes on startup
- Actual functionality broken

**Action:** Document, create issue, skip for now

#### 🤔 Unclear (Needs Investigation)
- Unexpected behavior
- Inconsistent results
- Environmental dependencies

**Action:** Document, ask for guidance

### Documentation Format

Create `BATCH-<N>-ISSUES.md`:

```markdown
# Batch 2 Issues

## Infrastructure Issues (Fixed)

### httpd - SSL Certificate
- **Issue:** curl failed with SSL verification error
- **Root Cause:** Minimal image lacks CA certificates
- **Fix:** Added `-k` flag to curl tests
- **Commit:** abc1234

## Image Issues (Reported)

### postgresql
- **Issue:** Database requires initialization before use
- **Root Cause:** Image needs initialization container/script
- **Status:** Documented, needs architecture discussion
- **Decision:** Skip for now, revisit in Phase 2

## Deferred

### memcached
- **Issue:** Requires connection client for testing
- **Status:** Need to determine if we install client or use different test
- **Action Required:** User decision needed
```

---

## Phase 6: INTEGRATE (Create Integration Tests)

### For Each Passing Image

Create `integration/` folder with real application:

#### Utility Images (curl, git, jq)
**Pattern:** CLI tool that uses the utility

```
<image>/integration/
├── Dockerfile              # Build using Hummingbird image
├── <app-script>.sh        # Application script
├── test-integration.sh    # Integration tests
└── README.md              # Documentation
```

#### Language Runtimes (Python, Node.js, Ruby, etc.)
**Pattern:** Web API or application

```
<image>/integration/
├── Dockerfile              # Build app with dependencies
├── app.<ext>              # Application code
├── requirements.txt       # Dependencies (if applicable)
├── test-integration.sh    # Integration tests
└── README.md              # Documentation
```

#### Web Servers (nginx, httpd, caddy)
**Pattern:** Static website with custom config

```
<image>/integration/
├── Dockerfile              # Build with custom config
├── <server>.conf          # Custom configuration
├── index.html             # Website files
├── test-integration.sh    # Integration tests
└── README.md              # Documentation
```

#### Databases (PostgreSQL, MariaDB, etc.)
**Pattern:** Database with initialization

```
<image>/integration/
├── Dockerfile              # Build with init scripts
├── init.sql               # Database initialization
├── test-integration.sh    # Integration tests (connect, query)
└── README.md              # Documentation
```

### Integration Test Checklist

For each integration test, validate:
- ✓ Build succeeds with image as base
- ✓ Dependencies install correctly
- ✓ Application runs successfully
- ✓ Real-world functionality works
- ✓ Cleanup happens automatically
- ✓ Tests are repeatable

---

## Phase 7: COMMIT (Batch Commit)

### Commit Strategy

**One commit per batch of 5 images** including:
- Basic tests for all 5
- Integration tests for all 5
- Documentation updates
- Any infrastructure fixes

### Commit Message Template

```
Add Batch <N> images: <img1>, <img2>, <img3>, <img4>, <img5>

Basic Tests:
- <img1>: <description> (4 tests)
- <img2>: <description> (4 tests)
- <img3>: <description> (4 tests)
- <img4>: <description> (4 tests)
- <img5>: <description> (4 tests)

Integration Tests:
- <img1>: <app description> (X scenarios)
- <img2>: <app description> (X scenarios)
- <img3>: <app description> (X scenarios)
- <img4>: <app description> (X scenarios)
- <img5>: <app description> (X scenarios)

Infrastructure Fixes:
- Fixed SSL certificate handling for curl-based images
- Added entrypoint specification for <language> images
- Updated image naming for <category> images

Known Issues:
- <img3>: Requires manual initialization (documented in BATCH-N-ISSUES.md)

Coverage: Now testing <total> of 44 images (<percentage>%)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Pre-Commit Checklist

Before committing batch:
- [ ] All 5 basic test scripts exist and are executable
- [ ] All 5 integration test folders created
- [ ] All tests run successfully (or issues documented)
- [ ] README files updated for each image
- [ ] `run-all-tests.sh` works with new images
- [ ] `run-all-integration-tests.sh` works with new images
- [ ] Documentation explains any special considerations
- [ ] Issues documented in BATCH-N-ISSUES.md (if any)

### Commit Commands

```bash
cd /workspace/artifacts/hummingbird-testing

# Stage all new tests
git add phase1-tests/

# Check what's being committed
git status

# Commit batch
git commit -m "<message from template>"

# Push to GitHub
git push
```

---

## Phase 8: REPEAT (Next Batch)

### Update Progress Tracking

Update `README.md`:

```markdown
## Current Status

### Phase 1: Build Verification

**Status:** 10/44 images tested (23%)

| Batch | Images | Status |
|-------|--------|--------|
| 1 | curl, jq, nginx, python-3-13, nodejs-22 | ✅ Complete |
| 2 | git, httpd, memcached, postgresql, valkey | ✅ Complete |
| 3 | ... | 🔄 In Progress |
```

### Select Next Batch

Review:
1. Completed images
2. Remaining images (44 - completed)
3. Apply selection criteria
4. Pick next 5

### Continuous Improvement

After each batch, update:
- Test templates based on learnings
- Documentation based on patterns
- Helper scripts for common tasks
- Infrastructure fixes applied globally

---

## Decision Matrix for Failures

Use this to categorize test failures:

| Symptom | Likely Cause | Action |
|---------|--------------|--------|
| "unauthorized" | Wrong image name | Fix: Check properties.yml |
| "image not found" | Wrong tag or doesn't exist | Fix: Verify in quay.io |
| "executable not found" | Missing entrypoint | Fix: Add explicit command |
| "SSL certificate" | Minimal image, no CA certs | Fix: Use -k or HTTP |
| "connection refused" | Service not started | Fix: Add sleep/retry |
| "permission denied" | Wrong user in test | Fix: Check user 0 vs 1001 |
| "address in use" | Port conflict | Fix: Unique ports or cleanup |
| Application crashes | Possible image bug | Report: Document and defer |
| Missing features | Image incomplete | Report: Document and defer |
| Inconsistent results | Race condition or environment | Investigate: More testing needed |

---

## Batch Velocity

### Time Estimates

| Phase | Time per Image | Total for Batch of 5 |
|-------|----------------|---------------------|
| SELECT | 5 min | 25 min |
| GENERATE | 15 min | 75 min (1.25 hrs) |
| EXECUTE | 5 min | 25 min |
| ITERATE | 10 min | 50 min |
| ANALYZE | 5 min | 25 min |
| INTEGRATE | 30 min | 150 min (2.5 hrs) |
| COMMIT | 10 min | 10 min |
| **TOTAL** | **~80 min** | **~6.5 hours** |

### Optimization Tips

1. **Generate all 5 in parallel** - Copy templates for all at once
2. **Run tests in batch** - Script to run all 5 sequentially
3. **Reuse patterns** - Similar images use same test structure
4. **Document as you go** - Don't defer documentation
5. **Fix infrastructure once** - Apply fix to all affected images

---

## Quality Gates

Before moving to next batch:

### Gate 1: Completeness
- ✓ All 5 images have basic tests
- ✓ All 5 images have integration tests
- ✓ All tests are documented

### Gate 2: Quality
- ✓ All tests run successfully OR issues documented
- ✓ Tests follow established patterns
- ✓ Documentation is clear and complete

### Gate 3: Integration
- ✓ Master test scripts updated
- ✓ README progress updated
- ✓ Changes committed and pushed

### Gate 4: Learning
- ✓ New patterns documented
- ✓ Infrastructure improvements noted
- ✓ Templates updated if needed

---

## Success Metrics

Track these for each batch:

1. **Completion Rate:** X/5 images fully tested
2. **Infrastructure Issues:** Count and types
3. **Image Issues:** Count and reported
4. **Test Coverage:** Total tests (basic + integration)
5. **Time Spent:** Actual vs estimated
6. **Quality:** Pass rate on first run

### Running Dashboard

```markdown
| Batch | Images | Basic Tests | Integration | Issues Fixed | Time |
|-------|--------|-------------|-------------|--------------|------|
| 1 | 5 | 20 (✓) | 41 (✓) | 3 | ~8h |
| 2 | 5 | 20 (✓) | 40 (✓) | 2 | ~7h |
| 3 | 5 | TBD | TBD | TBD | TBD |
```

---

## Automation Opportunities

### Helper Scripts to Create

1. **generate-test-template.sh**
   - Input: image name, category
   - Output: Pre-filled test directory

2. **validate-batch.sh**
   - Runs all tests in a batch
   - Reports success/failure
   - Identifies infrastructure vs image issues

3. **create-batch-commit.sh**
   - Generates commit message
   - Runs pre-commit checks
   - Commits and pushes

4. **check-image-name.sh**
   - Input: directory name
   - Output: Correct quay.io image name
   - Reads from properties.yml

---

## Example: Complete Batch 2 Walkthrough

See `BATCH-2-EXAMPLE.md` for detailed walkthrough of onboarding:
- git, httpd, memcached, postgresql, valkey

This includes:
- Selection rationale
- Complete test generation
- Actual failures encountered
- How they were categorized and fixed
- Integration test examples
- Final commit

---

## Continuous Improvement

After every 2-3 batches:

1. **Review patterns** - Are templates still accurate?
2. **Update templates** - Incorporate learnings
3. **Refine workflow** - Streamline based on experience
4. **Share knowledge** - Update documentation

### Pattern Library

As you onboard more images, build a library:

```
patterns/
├── utility-cli.md          # curl, git, jq pattern
├── language-runtime.md     # python, nodejs, ruby pattern
├── web-server.md           # nginx, httpd, caddy pattern
├── database.md             # postgresql, mariadb pattern
└── app-server.md           # tomcat pattern
```

Each pattern document includes:
- When to use this pattern
- Test template
- Integration test template
- Common pitfalls
- Example images

---

## Summary

This workflow enables systematic, repeatable onboarding of Hummingbird images in manageable batches:

1. **Structured** - Clear phases and steps
2. **Repeatable** - Same process for each batch
3. **Quality-focused** - Decision criteria and gates
4. **Learning** - Continuous improvement
5. **Scalable** - Can handle all 44 images

**Goal:** Complete all 44 images in ~9 batches at ~6-7 hours per batch = ~60 hours total effort

**Progress:** Batch 1 complete (5/44 = 11% done)
**Next:** Batch 2 (Utilities: git, httpd, memcached, postgresql, valkey)
