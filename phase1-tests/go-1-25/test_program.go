package main

import (
	"encoding/json"
	"fmt"
	"os"
	"runtime"
)

func main() {
	passed := 0
	failed := 0

	// Test 1: Basic output
	fmt.Println("Hello from Hummingbird Go 1.25!")
	passed++
	fmt.Println("  Basic Output - PASSED")

	// Test 2: JSON processing
	data := map[string]interface{}{"name": "test", "value": 123}
	jsonBytes, err := json.Marshal(data)
	if err != nil {
		fmt.Printf("  JSON Processing - FAILED: %v\n", err)
		failed++
	} else {
		var parsed map[string]interface{}
		err = json.Unmarshal(jsonBytes, &parsed)
		if err != nil || parsed["name"] != "test" {
			fmt.Printf("  JSON Processing - FAILED: parse error\n")
			failed++
		} else {
			fmt.Println("  JSON Processing - PASSED")
			passed++
		}
	}

	// Test 3: Runtime info
	if runtime.GOOS == "linux" {
		fmt.Println("  Runtime Info - PASSED")
		passed++
	} else {
		fmt.Printf("  Runtime Info - FAILED: expected linux, got %s\n", runtime.GOOS)
		failed++
	}

	// Test 4: File operations
	tmpFile := "/tmp/go-test-file.txt"
	err = os.WriteFile(tmpFile, []byte("test content\n"), 0644)
	if err != nil {
		fmt.Printf("  File Operations - FAILED: %v\n", err)
		failed++
	} else {
		content, err := os.ReadFile(tmpFile)
		if err != nil || string(content) != "test content\n" {
			fmt.Printf("  File Operations - FAILED: read error\n")
			failed++
		} else {
			fmt.Println("  File Operations - PASSED")
			passed++
		}
		os.Remove(tmpFile)
	}

	fmt.Printf("\nResults: %d passed, %d failed\n", passed, failed)
	if failed > 0 {
		os.Exit(1)
	}
}
