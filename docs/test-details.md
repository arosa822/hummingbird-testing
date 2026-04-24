# Test Details

What each Phase 1 test covers, organized by image. Every image runs 4 smoke tests using `set -euo pipefail` and supports both podman and docker via the `TEST_ENGINE` env var.

---

## Utilities & Tools

### curl

**Image:** `quay.io/hummingbird/curl:latest`
**Script:** [phase1-tests/curl/test.sh](../phase1-tests/curl/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Basic HTTP GET | Sends a request to example.com and expects HTTP 200 |
| 2 | Version check | Runs `curl --version` and confirms output contains "curl" |
| 3 | HTTPS/TLS support | Connects to google.com over HTTPS (with `-k` for minimal image) |
| 4 | JSON API fetch | Fetches JSON from httpbin.org and validates the response body |

---

### jq

**Image:** `quay.io/hummingbird/jq:latest`
**Script:** [phase1-tests/jq/test.sh](../phase1-tests/jq/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Field extraction | Extracts `.name` from a JSON object via stdin |
| 2 | Version check | Runs `jq --version` and confirms output contains "jq-" |
| 3 | Array processing | Accesses an array element by index (`.[1]`) |
| 4 | Nested filtering | Filters a nested JSON structure (`.users[0].name`) |

---

### git

**Image:** `quay.io/hummingbird/git:latest`
**Script:** [phase1-tests/git/test.sh](../phase1-tests/git/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `git --version` and confirms output |
| 2 | Help output | Runs `git --help` and checks for usage text |
| 3 | Init repository | Runs `git init` and confirms "Initialized" output |
| 4 | Clone repository | Shallow-clones a public GitHub repo and confirms success |

---

### memcached

**Image:** `quay.io/hummingbird/memcached:latest`
**Script:** [phase1-tests/memcached/test.sh](../phase1-tests/memcached/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `memcached -V` and confirms output |
| 2 | Container startup | Starts the container and confirms it is running |
| 3 | Key-value operations | Stores and retrieves a value using the memcached protocol via `nc` |
| 4 | Stats command | Sends `stats` command and validates response contains `STAT pid` |

---

## Web Servers

### nginx

**Image:** `quay.io/hummingbird/nginx:latest`
**Script:** [phase1-tests/nginx/test.sh](../phase1-tests/nginx/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts nginx and confirms the container is running |
| 2 | Serving content | Fetches the default page and checks for content (with retry) |
| 3 | HTTP status code | Confirms the server returns HTTP 200 |
| 4 | Log health check | Checks container logs for critical errors |

---

### caddy

**Image:** `quay.io/hummingbird/caddy:latest`
**Script:** [phase1-tests/caddy/test.sh](../phase1-tests/caddy/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts caddy and confirms the container is running |
| 2 | Serving content | Fetches the root URL and checks for a response (with retry) |
| 3 | HTTP response | Confirms the server returns HTTP 200 or 404 (server is alive) |
| 4 | Log health check | Checks container logs for panic/fatal errors |

---

### haproxy

**Image:** `quay.io/hummingbird/haproxy:latest`
**Script:** [phase1-tests/haproxy/test.sh](../phase1-tests/haproxy/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `haproxy -v` and confirms "HAProxy" in output |
| 2 | Config validation | Validates a test config file with `haproxy -c` |
| 3 | Container startup | Starts haproxy with a mounted config and confirms it is running |
| 4 | Stats endpoint | Hits the stats endpoint on port 8404 and expects HTTP 200 |

---

### httpd

**Image:** `quay.io/hummingbird/httpd:latest`
**Script:** [phase1-tests/httpd/test.sh](../phase1-tests/httpd/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts httpd and confirms the container is running |
| 2 | Serving content | Fetches the default page and checks for "It works" (with retry) |
| 3 | HTTP status code | Confirms the server returns HTTP 200 |
| 4 | Log health check | Checks container logs for critical errors |

---

## Language Runtimes

### python-3-13

**Image:** `quay.io/hummingbird/python:3.13`
**Script:** [phase1-tests/python-3-13/test.sh](../phase1-tests/python-3-13/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `python3 --version` and confirms "Python 3.13" |
| 2 | Inline execution | Runs `python3 -c "print('Hello, World!')"` |
| 3 | Standard library | Imports the `json` module and serializes data |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### python-3-12

**Image:** `quay.io/hummingbird/python:3.12`
**Script:** [phase1-tests/python-3-12/test.sh](../phase1-tests/python-3-12/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `python3 --version` and confirms "Python 3.12" |
| 2 | Inline execution | Runs `python3 -c "print('Hello, World!')"` |
| 3 | Standard library | Imports the `json` module and serializes data |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### python-3-11

**Image:** `quay.io/hummingbird/python:3.11`
**Script:** [phase1-tests/python-3-11/test.sh](../phase1-tests/python-3-11/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `python3 --version` and confirms "Python 3.11" |
| 2 | Inline execution | Runs `python3 -c "print('Hello, World!')"` |
| 3 | Standard library | Imports the `json` module and serializes data |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### python-3-14

**Image:** `quay.io/hummingbird/python:3.14`
**Script:** [phase1-tests/python-3-14/test.sh](../phase1-tests/python-3-14/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `python3 --version` and confirms "Python 3.14" |
| 2 | Inline execution | Runs `python3 -c "print('Hello, World!')"` |
| 3 | Standard library | Imports the `json` module and serializes data |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### nodejs-22

**Image:** `quay.io/hummingbird/nodejs:22`
**Script:** [phase1-tests/nodejs-22/test.sh](../phase1-tests/nodejs-22/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `node --version` and confirms "v22.x" |
| 2 | Inline execution | Runs `node -e "console.log('Hello, World!')"` |
| 3 | Built-in modules | Imports `os` module and checks `os.platform()` returns "linux" |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### nodejs-20

**Image:** `quay.io/hummingbird/nodejs:20`
**Script:** [phase1-tests/nodejs-20/test.sh](../phase1-tests/nodejs-20/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `node --version` and confirms "v20.x" |
| 2 | Inline execution | Runs `node -e "console.log('Hello, World!')"` |
| 3 | Built-in modules | Imports `os` module and checks `os.platform()` returns "linux" |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### nodejs-24

**Image:** `quay.io/hummingbird/nodejs:24`
**Script:** [phase1-tests/nodejs-24/test.sh](../phase1-tests/nodejs-24/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `node --version` and confirms "v24.x" |
| 2 | Inline execution | Runs `node -e "console.log('Hello, World!')"` |
| 3 | Built-in modules | Imports `os` module and checks `os.platform()` returns "linux" |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### nodejs-25

**Image:** `quay.io/hummingbird/nodejs:25`
**Script:** [phase1-tests/nodejs-25/test.sh](../phase1-tests/nodejs-25/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `node --version` and confirms "v25.x" |
| 2 | Inline execution | Runs `node -e "console.log('Hello, World!')"` |
| 3 | Built-in modules | Imports `os` module and checks `os.platform()` returns "linux" |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### go-1-25

**Image:** `quay.io/hummingbird/go:1.25`
**Script:** [phase1-tests/go-1-25/test.sh](../phase1-tests/go-1-25/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `go version` and confirms "go1.25" |
| 2 | Environment | Checks `GOPATH` and `GOROOT` are set |
| 3 | Compile and run | Mounts a `.go` file, runs it with `go run`, and validates output |
| 4 | Build toolchain | Compiles a `.go` file to a binary with `go build` |

---

### go-1-26

**Image:** `quay.io/hummingbird/go:1.26`
**Script:** [phase1-tests/go-1-26/test.sh](../phase1-tests/go-1-26/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `go version` and confirms "go1.26" |
| 2 | Environment | Checks `GOPATH` and `GOROOT` are set |
| 3 | Compile and run | Mounts a `.go` file, runs it with `go run`, and validates output |
| 4 | Build toolchain | Compiles a `.go` file to a binary with `go build` |

---

### rust

**Image:** `quay.io/hummingbird/rust:latest`
**Script:** [phase1-tests/rust/test.sh](../phase1-tests/rust/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Compiler version | Runs `rustc --version` and confirms output |
| 2 | Cargo version | Runs `cargo --version` and confirms output |
| 3 | Compile and run | Mounts a `.rs` file, compiles with `rustc`, and runs the binary |
| 4 | Toolchain sysroot | Runs `rustc --print sysroot` to verify the toolchain is intact |

---

### ruby-3-3

**Image:** `quay.io/hummingbird/ruby:3.3`
**Script:** [phase1-tests/ruby-3-3/test.sh](../phase1-tests/ruby-3-3/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `ruby --version` and confirms "ruby 3.3" |
| 2 | Inline execution | Runs `ruby -e "puts 'Hello, World!'"` |
| 3 | Standard library | Imports `json` and serializes a hash |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### ruby-3-4

**Image:** `quay.io/hummingbird/ruby:3.4`
**Script:** [phase1-tests/ruby-3-4/test.sh](../phase1-tests/ruby-3-4/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `ruby --version` and confirms "ruby 3.4" |
| 2 | Inline execution | Runs `ruby -e "puts 'Hello, World!'"` |
| 3 | Standard library | Imports `json` and serializes a hash |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### ruby-4-0

**Image:** `quay.io/hummingbird/ruby:4.0`
**Script:** [phase1-tests/ruby-4-0/test.sh](../phase1-tests/ruby-4-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `ruby --version` and confirms "ruby 4.0" |
| 2 | Inline execution | Runs `ruby -e "puts 'Hello, World!'"` |
| 3 | Standard library | Imports `json` and serializes a hash |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

### openjdk-21

**Image:** `quay.io/hummingbird/openjdk:21`
**Script:** [phase1-tests/openjdk-21/test.sh](../phase1-tests/openjdk-21/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Java version | Runs `java -version` and confirms "21" |
| 2 | Compiler version | Runs `javac -version` and confirms "21" |
| 3 | Compile and run | Mounts a `.java` file, compiles with `javac`, and runs it |
| 4 | JDK tools | Runs `jar --version` to verify JDK tools are available |

---

### openjdk-25

**Image:** `quay.io/hummingbird/openjdk:25`
**Script:** [phase1-tests/openjdk-25/test.sh](../phase1-tests/openjdk-25/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Java version | Runs `java -version` and confirms "25" |
| 2 | Compiler version | Runs `javac -version` and confirms "25" |
| 3 | Compile and run | Mounts a `.java` file, compiles with `javac`, and runs it |
| 4 | JDK tools | Runs `jar --version` to verify JDK tools are available |

---

### php

**Image:** `quay.io/hummingbird/php:latest`
**Script:** [phase1-tests/php/test.sh](../phase1-tests/php/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `php -v` and confirms "PHP" in output |
| 2 | Inline execution | Runs `php -r "echo 'Hello, World!';"` |
| 3 | Built-in functions | Uses `json_encode` to serialize data |
| 4 | Script execution | Mounts and runs a test script file that exercises core features |

---

## .NET / ASP.NET

### aspnet-runtime-8-0

**Image:** `quay.io/hummingbird/aspnet-runtime:8.0`
**Script:** [phase1-tests/aspnet-runtime-8-0/test.sh](../phase1-tests/aspnet-runtime-8-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `dotnet --info` and confirms "8.0" |
| 2 | Help output | Runs `dotnet --help` and checks for "Usage" text |
| 3 | List runtimes | Runs `dotnet --list-runtimes` and confirms `Microsoft.AspNetCore.App` |
| 4 | Version command | Runs `dotnet --version` and confirms it completes without crash |

---

### aspnet-runtime-9-0

**Image:** `quay.io/hummingbird/aspnet-runtime:9.0`
**Script:** [phase1-tests/aspnet-runtime-9-0/test.sh](../phase1-tests/aspnet-runtime-9-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `dotnet --info` and confirms "9.0" |
| 2 | Help output | Runs `dotnet --help` and checks for "Usage" text |
| 3 | List runtimes | Runs `dotnet --list-runtimes` and confirms `Microsoft.AspNetCore.App` |
| 4 | Version command | Runs `dotnet --version` and confirms it completes without crash |

---

### aspnet-runtime-10-0

**Image:** `quay.io/hummingbird/aspnet-runtime:10.0`
**Script:** [phase1-tests/aspnet-runtime-10-0/test.sh](../phase1-tests/aspnet-runtime-10-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `dotnet --info` and confirms "10.0" |
| 2 | Help output | Runs `dotnet --help` and checks for "Usage" text |
| 3 | List runtimes | Runs `dotnet --list-runtimes` and confirms `Microsoft.AspNetCore.App` |
| 4 | Version command | Runs `dotnet --version` and confirms it completes without crash |

---

### dotnet-runtime-8-0

**Image:** `quay.io/hummingbird/dotnet-runtime:8.0`
**Script:** [phase1-tests/dotnet-runtime-8-0/test.sh](../phase1-tests/dotnet-runtime-8-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `dotnet --info` and confirms "8.0" |
| 2 | Help output | Runs `dotnet --help` and checks for "Usage" text |
| 3 | List runtimes | Runs `dotnet --list-runtimes` and confirms `Microsoft.NETCore.App` |
| 4 | Version command | Runs `dotnet --version` and confirms it completes without crash |

---

### dotnet-runtime-9-0

**Image:** `quay.io/hummingbird/dotnet-runtime:9.0`
**Script:** [phase1-tests/dotnet-runtime-9-0/test.sh](../phase1-tests/dotnet-runtime-9-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `dotnet --info` and confirms "9.0" |
| 2 | Help output | Runs `dotnet --help` and checks for "Usage" text |
| 3 | List runtimes | Runs `dotnet --list-runtimes` and confirms `Microsoft.NETCore.App` |
| 4 | Version command | Runs `dotnet --version` and confirms it completes without crash |

---

### dotnet-runtime-10-0

**Image:** `quay.io/hummingbird/dotnet-runtime:10.0`
**Script:** [phase1-tests/dotnet-runtime-10-0/test.sh](../phase1-tests/dotnet-runtime-10-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `dotnet --info` and confirms "10.0" |
| 2 | Help output | Runs `dotnet --help` and checks for "Usage" text |
| 3 | List runtimes | Runs `dotnet --list-runtimes` and confirms `Microsoft.NETCore.App` |
| 4 | Version command | Runs `dotnet --version` and confirms it completes without crash |

---

### dotnet-sdk-8-0

**Image:** `quay.io/hummingbird/dotnet-sdk:8.0`
**Script:** [phase1-tests/dotnet-sdk-8-0/test.sh](../phase1-tests/dotnet-sdk-8-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | SDK version | Runs `dotnet --version` and confirms "8.0" |
| 2 | List SDKs | Runs `dotnet --list-sdks` and confirms "8.0" is listed |
| 3 | Create and build | Creates a console project with `dotnet new` and builds it |
| 4 | Run project | Creates and runs a console project, expects "Hello, World!" output |

---

### dotnet-sdk-9-0

**Image:** `quay.io/hummingbird/dotnet-sdk:9.0`
**Script:** [phase1-tests/dotnet-sdk-9-0/test.sh](../phase1-tests/dotnet-sdk-9-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | SDK version | Runs `dotnet --version` and confirms "9.0" |
| 2 | List SDKs | Runs `dotnet --list-sdks` and confirms "9.0" is listed |
| 3 | Create and build | Creates a console project with `dotnet new` and builds it |
| 4 | Run project | Creates and runs a console project, expects "Hello, World!" output |

---

### dotnet-sdk-10-0

**Image:** `quay.io/hummingbird/dotnet-sdk:10.0`
**Script:** [phase1-tests/dotnet-sdk-10-0/test.sh](../phase1-tests/dotnet-sdk-10-0/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | SDK version | Runs `dotnet --version` and confirms "10.0" |
| 2 | List SDKs | Runs `dotnet --list-sdks` and confirms "10.0" is listed |
| 3 | Create and build | Creates a console project with `dotnet new` and builds it |
| 4 | Run project | Creates and runs a console project, expects "Hello, World!" output |

---

## Databases

### mariadb-10-11

**Image:** `quay.io/hummingbird/mariadb:10.11`
**Script:** [phase1-tests/mariadb-10-11/test.sh](../phase1-tests/mariadb-10-11/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts MariaDB with a root password and waits for readiness |
| 2 | Version check | Queries `SELECT VERSION()` and confirms "10.11" or "MariaDB" |
| 3 | SQL operations | Creates a database/table, inserts a row, and queries it back |
| 4 | Log health check | Checks container logs for fatal/crash errors |

---

### mariadb-11-8

**Image:** `quay.io/hummingbird/mariadb:11.8`
**Script:** [phase1-tests/mariadb-11-8/test.sh](../phase1-tests/mariadb-11-8/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts MariaDB with a root password and waits for readiness |
| 2 | Version check | Queries `SELECT VERSION()` and confirms "11.8" or "MariaDB" |
| 3 | SQL operations | Creates a database/table, inserts a row, and queries it back |
| 4 | Log health check | Checks container logs for fatal/crash errors |

---

### postgresql

**Image:** `quay.io/hummingbird/postgresql:latest`
**Script:** [phase1-tests/postgresql/test.sh](../phase1-tests/postgresql/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts PostgreSQL with a password and waits for readiness |
| 2 | Version check | Queries `SELECT version()` and confirms "postgresql" |
| 3 | SQL operations | Creates a table, inserts a row, and queries it back |
| 4 | Log health check | Checks container logs for FATAL/PANIC errors |

---

### valkey

**Image:** `quay.io/hummingbird/valkey:latest`
**Script:** [phase1-tests/valkey/test.sh](../phase1-tests/valkey/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts Valkey and confirms the container is running |
| 2 | PING/PONG | Sends `PING` via `valkey-cli` and expects `PONG` |
| 3 | Key-value operations | Sets and gets a key using `valkey-cli` |
| 4 | Server info | Runs `INFO server` and confirms `valkey_version` is present |

---

## Application Servers

### tomcat-10

**Image:** `quay.io/hummingbird/tomcat:10`
**Script:** [phase1-tests/tomcat-10/test.sh](../phase1-tests/tomcat-10/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts Tomcat and confirms the container is running |
| 2 | HTTP response | Fetches the root URL and checks for HTTP 200 or 404 (with retry) |
| 3 | Version in logs | Checks container logs for Tomcat/Catalina startup messages |
| 4 | Log health check | Checks container logs for SEVERE/fatal errors |

---

### tomcat-11

**Image:** `quay.io/hummingbird/tomcat:11`
**Script:** [phase1-tests/tomcat-11/test.sh](../phase1-tests/tomcat-11/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Container startup | Starts Tomcat and confirms the container is running |
| 2 | HTTP response | Fetches the root URL and checks for HTTP 200 or 404 (with retry) |
| 3 | Version in logs | Checks container logs for Tomcat/Catalina startup messages |
| 4 | Log health check | Checks container logs for SEVERE/fatal errors |

---

## Specialized

### core-runtime

**Image:** `quay.io/hummingbird/core-runtime:latest`
**Script:** [phase1-tests/core-runtime/test.sh](../phase1-tests/core-runtime/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | OS info | Reads `/etc/os-release` and confirms "Hummingbird" |
| 2 | Bash execution | Runs `bash -c "echo 'Hello, World!'"` |
| 3 | Coreutils | Lists root filesystem and checks for `usr` and `etc` directories |
| 4 | File operations | Writes a file to `/tmp` and reads it back |

---

### xcaddy

**Image:** `quay.io/hummingbird/xcaddy:latest`
**Script:** [phase1-tests/xcaddy/test.sh](../phase1-tests/xcaddy/test.sh)

| # | Test | What it verifies |
|---|------|------------------|
| 1 | Version check | Runs `xcaddy version` and confirms output is non-empty |
| 2 | Help output | Runs `xcaddy help` and checks for usage information |
| 3 | Build subcommand | Runs `xcaddy build --help` to confirm the build command is available |
| 4 | Go toolchain | Runs `go version` to verify Go is available (required by xcaddy) |
