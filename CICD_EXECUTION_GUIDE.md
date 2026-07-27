# CI/CD Execution Guide - GitHub Actions

This guide explains the automated CI/CD pipeline configured for **Drift Mind**.

## Workflow Triggering

The workflow located at `.github/workflows/deploy-and-test.yml` triggers automatically on:
- Every `push` to `main` / `master`
- Every `pull_request` to `main` / `master`
- Manual trigger via **Workflow Dispatch** in GitHub Actions tab.

## 13 Pipeline Stages

1. **Stage 1: Repository Checkout**: Checks out codebase.
2. **Stage 2: Dependency Installation**: Prepares Flutter SDK & Python environments.
3. **Stage 3: Build Application**: Builds Flutter Web bundle with `--base-href /Drift_Mind/`.
4. **Stage 4: Static Analysis**: Runs `flutter analyze`.
5. **Stage 5: Deploy to GitHub Pages**: Deploys `build/web` to GitHub Pages.
6. **Stage 6: Wait for Deployment**: Polling loop verifying live site deployment.
7. **Stage 7: Deployment Verification**: Ensures HTTP status 200 from live target URL.
8. **Stage 8: Run Selenium E2E Tests**: Executes 400+ test cases using Headless Chrome.
9. **Stage 9: Generate HTML Reports**: Produces interactive HTML reports.
10. **Stage 10: Generate Excel Reports**: Creates multi-sheet Excel workbooks.
11. **Stage 11: Upload Artifacts**: Uploads evidence bundle retained for 30 days.
12. **Stage 12: Publish Summary**: Renders summary tables directly on GitHub Actions summary tab.
13. **Stage 13: Store Historical Results**: Preserves execution history.

## Required GitHub Repository Settings

1. Go to **Settings > Pages**.
2. Under **Build and deployment > Source**, select **GitHub Actions**.
3. Go to **Settings > Actions > General > Workflow permissions**, select **Read and write permissions**.
