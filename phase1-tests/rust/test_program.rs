use std::collections::HashMap;

fn main() {
    let mut passed = 0;
    let mut failed = 0;

    // Test 1: Basic output
    println!("Hello from Hummingbird Rust!");
    passed += 1;
    println!("  Basic Output - PASSED");

    // Test 2: JSON-like data structure
    let mut data: HashMap<&str, &str> = HashMap::new();
    data.insert("name", "test");
    data.insert("value", "123");
    if data.get("name") == Some(&"test") && data.get("value") == Some(&"123") {
        println!("  HashMap Operations - PASSED");
        passed += 1;
    } else {
        println!("  HashMap Operations - FAILED");
        failed += 1;
    }

    // Test 3: String processing
    let text = "hummingbird rust test";
    let upper = text.to_uppercase();
    if upper == "HUMMINGBIRD RUST TEST" {
        println!("  String Processing - PASSED");
        passed += 1;
    } else {
        println!("  String Processing - FAILED: got {}", upper);
        failed += 1;
    }

    // Test 4: File operations
    let tmp_path = "/tmp/rust-test-file.txt";
    match std::fs::write(tmp_path, "test content\n") {
        Ok(_) => {
            match std::fs::read_to_string(tmp_path) {
                Ok(content) if content == "test content\n" => {
                    println!("  File Operations - PASSED");
                    passed += 1;
                }
                _ => {
                    println!("  File Operations - FAILED: read mismatch");
                    failed += 1;
                }
            }
            let _ = std::fs::remove_file(tmp_path);
        }
        Err(e) => {
            println!("  File Operations - FAILED: {}", e);
            failed += 1;
        }
    }

    println!("\nResults: {} passed, {} failed", passed, failed);
    if failed > 0 {
        std::process::exit(1);
    }
}
