# Local Execution Guide - Drift Mind Selenium E2E Automation

This guide provides instructions for running the complete Selenium E2E automation test suite locally against the live deployed GitHub Pages application.

## Prerequisites

1. **Python 3.10+**: Ensure Python is installed on your machine.
2. **Google Chrome**: Ensure Chrome browser is installed.
3. **Flutter SDK** (Optional for local web build): Installed if building the web app locally.

## Setup Instructions

1. Open terminal/powershell in the project root:
   ```bash
   cd c:\Users\nasri\OneDrive\Desktop\drift_mind\drift_mind
   ```

2. Install Python dependencies:
   ```bash
   pip install -r automation/requirements.txt
   ```

## Running Tests

### 1. Execute All 400+ Test Cases
```bash
python automation/run_tests.py
```

### 2. Override Live Base URL (Optional)
```bash
BASE_URL="https://paramu5068.github.io/Drift_Mind/" python automation/run_tests.py
```

### 3. Run Specific Test Category
```bash
pytest automation/tests/test_01_authentication.py -c automation/pytest.ini
```

## Viewing Generated Reports

After execution completes, all reports are saved under `Test Results/`:
- **Excel Reports**: `Test Results/Excel/Automation_Test_Report.xlsx`
- **HTML Dashboard**: `Test Results/HTML/dashboard.html`
- **JSON Results**: `Test Results/JSON/execution-results.json`
- **Logs**: `Test Results/Logs/automation.log`
