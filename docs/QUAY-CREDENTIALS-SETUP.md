# Setting Up Quay.io Credentials for GitHub Actions

The Hummingbird container images on quay.io require authentication. This guide shows how to configure GitHub Secrets so the workflow can authenticate.

## Step 1: Get Quay.io Credentials

You need credentials that have read access to the `quay.io/hummingbird` organization.

### Option A: Use Your Personal Quay.io Account
1. Log in to https://quay.io
2. Navigate to Account Settings
3. Create a Robot Account or use your personal credentials
4. Make sure the account has access to pull from `quay.io/hummingbird/*` images

### Option B: Create a Robot Account (Recommended for CI/CD)
1. Log in to https://quay.io
2. Go to the Hummingbird organization
3. Click "Robot Accounts" → "Create Robot Account"
4. Name it something like `github-actions-reader`
5. Grant "Read" permissions for the repositories you need
6. Save the username and token

## Step 2: Add Secrets to GitHub

1. Go to your GitHub repository: https://github.com/arosa822/hummingbird-testing

2. Click **Settings** → **Secrets and variables** → **Actions**

3. Click **New repository secret**

4. Add the first secret:
   - **Name**: `QUAY_USERNAME`
   - **Value**: Your quay.io username (e.g., `yourname` or `hummingbird+robot`)
   - Click **Add secret**

5. Add the second secret:
   - **Name**: `QUAY_PASSWORD`
   - **Value**: Your quay.io password or robot token
   - Click **Add secret**

## Step 3: Verify Secrets Are Set

After adding both secrets, you should see:
- ✓ `QUAY_USERNAME` - Updated X seconds ago
- ✓ `QUAY_PASSWORD` - Updated X seconds ago

## Step 4: Update Workflow File

The updated `workflow-example.yml` now includes login steps:

```yaml
- name: Login to Quay.io
  uses: docker/login-action@v3
  with:
    registry: quay.io
    username: ${{ secrets.QUAY_USERNAME }}
    password: ${{ secrets.QUAY_PASSWORD }}
```

Copy the updated workflow to your `.github/workflows/` directory:

```bash
mkdir -p .github/workflows
cp phase1-tests/workflow-example.yml .github/workflows/phase1-tests.yml
git add .github/workflows/phase1-tests.yml
git commit -m "Add Phase 1 tests with Quay.io authentication"
git push
```

## Step 5: Test the Workflow

1. Push a change to trigger the workflow, or
2. Go to **Actions** tab → Select the workflow → Click **Run workflow**

The workflow should now successfully:
1. Log in to quay.io
2. Pull images from `quay.io/hummingbird/*`
3. Run all tests

## Troubleshooting

### Still Getting "unauthorized" Error?

**Check 1: Verify credentials work locally**
```bash
docker login quay.io
# Enter your username and password
# Should see: Login Succeeded

docker pull quay.io/hummingbird/curl:latest
# Should successfully pull the image
```

**Check 2: Verify GitHub secrets are set correctly**
- Go to Settings → Secrets and variables → Actions
- Ensure both `QUAY_USERNAME` and `QUAY_PASSWORD` exist
- Secret names are case-sensitive

**Check 3: Verify robot account permissions**
- If using a robot account, ensure it has read access to the repositories
- Check in Quay.io → Organization → Robot Accounts → Permissions

**Check 4: Check for typos in workflow file**
- Ensure secrets are referenced as `${{ secrets.QUAY_USERNAME }}`
- Ensure registry is `quay.io` (not `quay.io/hummingbird`)

### Error: "repository does not exist"

This means the image path might be wrong. Verify the correct image names:
- `quay.io/hummingbird/curl:latest`
- `quay.io/hummingbird/jq:latest`
- `quay.io/hummingbird/nginx:latest`
- `quay.io/hummingbird/python-3-13:latest`
- `quay.io/hummingbird/nodejs-22:latest`

If the organization or repository names are different, update the test scripts accordingly.

## Security Notes

✅ **Do:**
- Use Robot Accounts for CI/CD (better than personal credentials)
- Grant minimum required permissions (read-only for pulling images)
- Rotate credentials periodically
- Use GitHub Secrets (never commit credentials to git)

❌ **Don't:**
- Commit credentials to the repository
- Share credentials in public issues or pull requests
- Use write permissions when read is sufficient
- Hardcode credentials in workflow files

## Alternative: Public Images

If the Hummingbird images can be made public:
1. Change image visibility in Quay.io to "Public"
2. Remove the login step from the workflow
3. Images will pull without authentication

This is simpler but only works if images don't need to be private.
