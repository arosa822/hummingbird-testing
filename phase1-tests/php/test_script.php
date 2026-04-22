<?php
$passed = 0;
$failed = 0;

function run_test($name, $fn) {
    global $passed, $failed;
    try {
        $fn();
        echo "  $name - PASSED\n";
        $passed++;
    } catch (Exception $e) {
        echo "  $name - FAILED: " . $e->getMessage() . "\n";
        $failed++;
    }
}

echo "Hello from Hummingbird PHP!\n";

run_test("Basic Output", function() {
    // Already printed above
});

run_test("JSON Processing", function() {
    $data = ["name" => "test", "value" => 123];
    $json = json_encode($data);
    $parsed = json_decode($json, true);
    if ($parsed["name"] !== "test" || $parsed["value"] !== 123) {
        throw new Exception("JSON mismatch");
    }
});

run_test("Array Operations", function() {
    $squares = array_map(function($x) { return $x ** 2; }, range(0, 4));
    if ($squares !== [0, 1, 4, 9, 16]) {
        throw new Exception("Array mismatch");
    }
});

run_test("File Operations", function() {
    $tmpFile = tempnam(sys_get_temp_dir(), 'php-test-');
    file_put_contents($tmpFile, "test content\n");
    $content = file_get_contents($tmpFile);
    unlink($tmpFile);
    if ($content !== "test content\n") {
        throw new Exception("Content mismatch");
    }
});

echo "\nResults: $passed passed, $failed failed\n";
exit($failed > 0 ? 1 : 0);
