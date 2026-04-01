#!/usr/bin/env python3
"""
Fetch and display the latest GitHub Actions workflow run results
for the Phase 1 tests.
"""

import json
import os
import sys
import subprocess
from datetime import datetime

# Configuration
REPO_OWNER = "arosa822"
REPO_NAME = "hummingbird-testing"
WORKFLOW_NAME = "phase1-tests.yml"  # or "Phase 1 - Build Verification Tests"


def run_gh_command(args):
    """Run gh CLI command and return JSON output"""
    try:
        result = subprocess.run(
            ["gh"] + args,
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running gh command: {e}", file=sys.stderr)
        print(f"stderr: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        sys.exit(1)


def get_latest_workflow_run():
    """Get the latest workflow run"""
    print(f"Fetching latest workflow run for {REPO_OWNER}/{REPO_NAME}...")
    print()

    # Get workflow runs using gh run list
    runs = run_gh_command([
        "run", "list",
        "--repo", f"{REPO_OWNER}/{REPO_NAME}",
        "--limit", "1",
        "--json", "databaseId,status,conclusion,headBranch,workflowName,createdAt,url,displayTitle"
    ])

    if not runs or len(runs) == 0:
        print("No workflow runs found.")
        return None

    return runs[0]


def get_workflow_jobs(run_id):
    """Get jobs for a specific workflow run"""
    data = run_gh_command([
        "api",
        f"/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs/{run_id}/jobs",
    ])

    return data.get("jobs", [])


def get_job_logs(job_id):
    """Get logs for a specific job"""
    try:
        result = subprocess.run(
            ["gh", "api", f"/repos/{REPO_OWNER}/{REPO_NAME}/actions/jobs/{job_id}/logs"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError:
        return None


def format_timestamp(timestamp_str):
    """Format ISO timestamp to readable format"""
    try:
        dt = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
        return dt.strftime('%Y-%m-%d %H:%M:%S UTC')
    except:
        return timestamp_str


def print_run_summary(run):
    """Print workflow run summary"""
    print("=" * 80)
    print("LATEST WORKFLOW RUN")
    print("=" * 80)
    print(f"Workflow:    {run.get('workflowName', 'N/A')}")
    print(f"Title:       {run.get('displayTitle', 'N/A')}")
    print(f"Run ID:      {run.get('databaseId', 'N/A')}")
    print(f"Status:      {run.get('status', 'N/A')}")
    print(f"Conclusion:  {run.get('conclusion', 'N/A')}")
    print(f"Branch:      {run.get('headBranch', 'N/A')}")
    print(f"Created:     {format_timestamp(run.get('createdAt', 'N/A'))}")
    print(f"URL:         {run.get('url', 'N/A')}")
    print("=" * 80)
    print()


def print_job_status(jobs, show_logs=False):
    """Print status of all jobs"""
    print("JOB RESULTS")
    print("=" * 80)

    passed = 0
    failed = 0

    for job in jobs:
        job_name = job.get("name", "Unknown")
        status = job.get("status", "unknown")
        conclusion = job.get("conclusion", "unknown")

        # Determine symbol
        if conclusion == "success":
            symbol = "✓"
            passed += 1
        elif conclusion == "failure":
            symbol = "✗"
            failed += 1
        elif conclusion == "skipped":
            symbol = "⊘"
        else:
            symbol = "⋯"

        print(f"{symbol} {job_name:<40} {status:<15} {conclusion}")

        # Show logs for failed jobs if requested
        if show_logs and conclusion == "failure":
            print(f"\n  --- Logs for {job_name} ---")
            logs = get_job_logs(job.get("id"))
            if logs:
                # Show last 50 lines of logs
                log_lines = logs.split('\n')
                relevant_lines = [l for l in log_lines if l.strip()][-50:]
                for line in relevant_lines:
                    print(f"  {line}")
            print()

    print("=" * 80)
    print(f"\nSummary: {passed} passed, {failed} failed out of {len(jobs)} jobs")
    print()


def main():
    """Main function"""
    # Check if gh CLI is available
    try:
        subprocess.run(["gh", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: GitHub CLI (gh) is not installed or not in PATH")
        print("Install it from: https://cli.github.com/")
        sys.exit(1)

    # Check if authenticated
    try:
        subprocess.run(["gh", "auth", "status"], capture_output=True, check=True)
    except subprocess.CalledProcessError:
        print("Error: Not authenticated with GitHub")
        print("Run: gh auth login")
        sys.exit(1)

    # Get command line args
    show_logs = "--logs" in sys.argv or "-l" in sys.argv

    # Fetch latest run
    run = get_latest_workflow_run()

    if not run:
        print("No workflow runs found.")
        sys.exit(1)

    # Print run summary
    print_run_summary(run)

    # Get and print jobs
    run_id = run.get("databaseId", run.get("id"))
    jobs = get_workflow_jobs(run_id)

    if jobs:
        print_job_status(jobs, show_logs=show_logs)
    else:
        print("No jobs found for this run.")

    # Exit with appropriate code
    conclusion = run.get("conclusion")
    if conclusion == "success":
        sys.exit(0)
    elif conclusion == "failure":
        sys.exit(1)
    else:
        sys.exit(2)


if __name__ == "__main__":
    main()
