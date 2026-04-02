#!/bin/bash
# Generate test template for a new image
# Usage: ./generate-test-template.sh <image-name> <category>
# Categories: utility, language, webserver, database, appserver

set -euo pipefail

IMAGE_NAME="${1:-}"
CATEGORY="${2:-utility}"
PHASE1_DIR="/workspace/artifacts/hummingbird-testing/phase1-tests"

if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image-name> [category]"
    echo ""
    echo "Categories:"
    echo "  utility    - CLI tools (curl, jq, git)"
    echo "  language   - Runtime environments (python, nodejs, ruby)"
    echo "  webserver  - Web servers (nginx, httpd, caddy)"
    echo "  database   - Databases (postgresql, mariadb)"
    echo "  appserver  - Application servers (tomcat)"
    echo ""
    echo "Example: $0 git utility"
    exit 1
fi

TARGET_DIR="${PHASE1_DIR}/${IMAGE_NAME}"

if [ -d "$TARGET_DIR" ]; then
    echo "❌ ERROR: Directory already exists: $TARGET_DIR"
    echo "Remove it first or choose a different name"
    exit 1
fi

echo "=========================================="
echo "Generating Test Template"
echo "=========================================="
echo "Image: $IMAGE_NAME"
echo "Category: $CATEGORY"
echo "Target: $TARGET_DIR"
echo ""

# Determine template source based on category
case "$CATEGORY" in
    utility)
        TEMPLATE_SOURCE="curl"
        echo "Using utility template (curl)"
        ;;
    language)
        TEMPLATE_SOURCE="python-3-13"
        echo "Using language runtime template (python-3-13)"
        ;;
    webserver)
        TEMPLATE_SOURCE="nginx"
        echo "Using web server template (nginx)"
        ;;
    database)
        TEMPLATE_SOURCE="postgresql"
        echo "Using database template (if available, else utility)"
        if [ ! -d "${PHASE1_DIR}/postgresql" ]; then
            TEMPLATE_SOURCE="curl"
            echo "PostgreSQL template not yet available, using utility"
        fi
        ;;
    appserver)
        TEMPLATE_SOURCE="nginx"
        echo "Using app server template (nginx-like)"
        ;;
    *)
        echo "⚠️  Unknown category, using utility template"
        TEMPLATE_SOURCE="curl"
        ;;
esac

TEMPLATE_DIR="${PHASE1_DIR}/${TEMPLATE_SOURCE}"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "❌ ERROR: Template directory not found: $TEMPLATE_DIR"
    exit 1
fi

# Create target directory
mkdir -p "$TARGET_DIR"
echo "✓ Created directory: $TARGET_DIR"

# Copy template files
echo ""
echo "Copying template files..."

# Copy basic test files
cp "${TEMPLATE_DIR}/test.sh" "$TARGET_DIR/"
echo "  ✓ test.sh"

cp "${TEMPLATE_DIR}/Dockerfile" "$TARGET_DIR/"
echo "  ✓ Dockerfile"

cp "${TEMPLATE_DIR}/README.md" "$TARGET_DIR/"
echo "  ✓ README.md"

# Copy language-specific test scripts if they exist
if [ -f "${TEMPLATE_DIR}/test_script.py" ]; then
    cp "${TEMPLATE_DIR}/test_script.py" "$TARGET_DIR/"
    echo "  ✓ test_script.py"
fi

if [ -f "${TEMPLATE_DIR}/test_script.js" ]; then
    cp "${TEMPLATE_DIR}/test_script.js" "$TARGET_DIR/"
    echo "  ✓ test_script.js"
fi

# Copy test plan from root if it exists
ROOT_TEST_PLAN="/workspace/artifacts/hummingbird-testing/test-${IMAGE_NAME}.md"
if [ -f "$ROOT_TEST_PLAN" ]; then
    cp "$ROOT_TEST_PLAN" "$TARGET_DIR/"
    echo "  ✓ test-${IMAGE_NAME}.md"
else
    echo "  ⚠️  test-${IMAGE_NAME}.md not found in root (ok to skip)"
fi

# Make test script executable
chmod +x "${TARGET_DIR}/test.sh"

echo ""
echo "=========================================="
echo "Template Generated Successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Get correct image name:"
echo "   ./scripts/check-image-name.sh $IMAGE_NAME"
echo ""
echo "2. Edit the test script:"
echo "   cd ${TARGET_DIR}"
echo "   vi test.sh"
echo "   # Update IMAGE variable with correct name"
echo "   # Customize tests for $IMAGE_NAME"
echo ""
echo "3. Update documentation:"
echo "   vi README.md"
echo "   # Update descriptions and examples"
echo ""
echo "4. Run the test:"
echo "   ./test.sh"
echo ""
echo "5. Create integration tests:"
echo "   mkdir integration"
echo "   # Add Dockerfile, app code, test-integration.sh"
echo ""
echo "Generated files:"
ls -1 "$TARGET_DIR"
