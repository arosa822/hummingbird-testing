# Phase 1 Test: nodejs-22

## Test Strategy

This test validates that the Hummingbird Node.js 22 image can execute JavaScript code and access built-in modules.

## Tests Included

### Test 1: Version Verification
- **What it does**: Runs `node --version` to check Node.js version
- **Why**: Confirms Node.js 22.x is installed correctly
- **Pass criteria**: Output contains "v22."

### Test 2: Inline Code Execution
- **What it does**: Executes simple `console.log('Hello, World!')` inline
- **Why**: Verifies basic JavaScript execution works
- **Pass criteria**: Outputs "Hello, World!"

### Test 3: Built-in Modules Access
- **What it does**: Requires and uses the `os` module to get platform
- **Why**: Validates Node.js built-in modules are available
- **Pass criteria**: Successfully detects Linux platform

### Test 4: Script File Execution
- **What it does**: Runs `test_script.js` with comprehensive tests
- **Why**: Tests real-world usage with modules, ES6+ features, and file I/O
- **Pass criteria**: All 4 internal tests pass (console, JSON, modern JS, file I/O)

## Running Tests

```bash
# Make script executable
chmod +x test.sh

# Run tests with podman (default)
./test.sh

# Run tests with docker
TEST_ENGINE=docker ./test.sh
```

## Files

- `Dockerfile` - Extends Node.js image with test script
- `test.sh` - Automated bash test script
- `test_script.js` - JavaScript test script with 4 internal tests
- `test-nodejs-22.md` - Original comprehensive test plan
- `README.md` - This file

## Success Criteria

All 4 bash tests must pass, including the JavaScript script which runs 4 additional internal tests.
