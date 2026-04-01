# Phase 1 Test: python-3-13

## Test Strategy

This test validates that the Hummingbird Python 3.13 image can execute Python code and access standard libraries.

## Tests Included

### Test 1: Version Verification
- **What it does**: Runs `python --version` to check Python version
- **Why**: Confirms Python 3.13 is installed correctly
- **Pass criteria**: Output contains "Python 3.13"

### Test 2: Inline Code Execution
- **What it does**: Executes simple `print('Hello, World!')` inline
- **Why**: Verifies basic Python execution works
- **Pass criteria**: Outputs "Hello, World!"

### Test 3: Standard Library Access
- **What it does**: Imports and uses the `json` module
- **Why**: Validates Python standard library is available
- **Pass criteria**: Successfully serializes JSON

### Test 4: Script File Execution
- **What it does**: Runs `test_script.py` with comprehensive tests
- **Why**: Tests real-world usage with file I/O, modules, and Python features
- **Pass criteria**: All 4 internal tests pass (print, JSON, list comprehension, file I/O)

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

- `Dockerfile` - Extends Python image with test script
- `test.sh` - Automated bash test script
- `test_script.py` - Python test script with 4 internal tests
- `test-python-3-13.md` - Original comprehensive test plan
- `README.md` - This file

## Success Criteria

All 4 bash tests must pass, including the Python script which runs 4 additional internal tests.
