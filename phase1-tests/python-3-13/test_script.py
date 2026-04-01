#!/usr/bin/env python3
"""Simple Python test script for Hummingbird python-3-13 image"""

import json
import sys

def test_basic_print():
    """Test basic print functionality"""
    print("Hello from Hummingbird Python 3.13!")
    return True

def test_json_processing():
    """Test JSON module is available"""
    data = {"name": "test", "value": 123}
    json_str = json.dumps(data)
    parsed = json.loads(json_str)
    assert parsed["name"] == "test"
    assert parsed["value"] == 123
    return True

def test_list_comprehension():
    """Test Python list comprehension"""
    squares = [x**2 for x in range(5)]
    assert squares == [0, 1, 4, 9, 16]
    return True

def test_file_operations():
    """Test basic file I/O"""
    import tempfile
    import os

    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write("test content\n")
        temp_path = f.name

    try:
        with open(temp_path, 'r') as f:
            content = f.read()
        assert content == "test content\n"
        return True
    finally:
        os.unlink(temp_path)

if __name__ == "__main__":
    tests = [
        ("Basic Print", test_basic_print),
        ("JSON Processing", test_json_processing),
        ("List Comprehension", test_list_comprehension),
        ("File Operations", test_file_operations),
    ]

    passed = 0
    failed = 0

    for name, test_func in tests:
        try:
            test_func()
            print(f"✓ {name} - PASSED")
            passed += 1
        except Exception as e:
            print(f"✗ {name} - FAILED: {e}")
            failed += 1

    print(f"\nResults: {passed} passed, {failed} failed")
    sys.exit(0 if failed == 0 else 1)
