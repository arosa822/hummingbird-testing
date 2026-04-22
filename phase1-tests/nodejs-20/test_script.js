#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const os = require('os');

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`  ${name} - PASSED`);
    passed++;
  } catch (error) {
    console.log(`  ${name} - FAILED: ${error.message}`);
    failed++;
  }
}

test('Basic Console Output', () => {
  console.log('Hello from Hummingbird Node.js 20!');
});

test('JSON Processing', () => {
  const data = { name: 'test', value: 123 };
  const jsonStr = JSON.stringify(data);
  const parsed = JSON.parse(jsonStr);
  if (parsed.name !== 'test' || parsed.value !== 123) {
    throw new Error('JSON parsing failed');
  }
});

test('Modern JavaScript Features', () => {
  const numbers = [1, 2, 3, 4, 5];
  const doubled = numbers.map(n => n * 2);
  const sum = doubled.reduce((acc, n) => acc + n, 0);
  if (sum !== 30) {
    throw new Error(`Expected sum of 30, got ${sum}`);
  }
});

test('File I/O Operations', () => {
  const tmpDir = os.tmpdir();
  const testFile = path.join(tmpDir, `test-${Date.now()}.txt`);
  const testContent = 'Node.js file test\n';
  try {
    fs.writeFileSync(testFile, testContent);
    const content = fs.readFileSync(testFile, 'utf8');
    if (content !== testContent) {
      throw new Error('File content mismatch');
    }
  } finally {
    if (fs.existsSync(testFile)) {
      fs.unlinkSync(testFile);
    }
  }
});

console.log(`\nResults: ${passed} passed, ${failed} failed`);
process.exit(failed === 0 ? 0 : 1);
