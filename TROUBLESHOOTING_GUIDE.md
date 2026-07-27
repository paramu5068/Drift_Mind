# Troubleshooting Guide - Live E2E CI/CD Pipeline

Common issues and resolution steps for the Drift Mind testing pipeline.

## 1. GitHub Pages 404 or Deployment Delay
**Symptom**: Deployment verification stage times out or returns 404.
**Solution**:
- Ensure repository settings under **Settings > Pages** have source set to **GitHub Actions**.
- Check that the base href in build step matches repository name: `flutter build web --release --base-href /Drift_Mind/`.

## 2. Chrome Driver Initialization Error in Actions
**Symptom**: `WebDriverException: chrome not reachable`.
**Solution**:
- Options in `DriverFactory` must include `--headless=new`, `--no-sandbox`, and `--disable-dev-shm-usage`.

## 3. Flutter Canvas Web Render Delay
**Symptom**: Elements not immediately found on initial page load.
**Solution**:
- The framework uses `BasePage.wait_for_flutter()` to poll until the Flutter canvas or root view initializes.

## 4. Missing Excel or HTML Reports
**Symptom**: Artifact upload step fails or reports are missing.
**Solution**:
- Ensure `openpyxl`, `pandas`, and `jinja2` are listed in `automation/requirements.txt`.
