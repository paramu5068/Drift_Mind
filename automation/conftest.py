import pytest
import time
from automation.drivers.driver_factory import DriverFactory
from automation.config.config import Config
from automation.utils.screenshot_utils import capture_screenshot
from automation.utils.logger import logger

RESULTS_COLLECTION = []
START_TIME = 0.0

def pytest_configure(config):
    global START_TIME
    START_TIME = time.time()
    Config.ensure_directories()

@pytest.fixture(scope="session")
def driver():
    driver_instance = DriverFactory.create_driver()
    driver_instance.get(Config.BASE_URL)
    yield driver_instance
    driver_instance.quit()

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    report = outcome.get_result()
    
    if report.when == "call":
        test_id = getattr(item.function, "test_id", item.name)
        module = getattr(item.function, "module", item.module.__name__.split('.')[-1].replace('test_', '').title())
        priority = getattr(item.function, "priority", "P2")
        duration = round(report.duration, 3)
        
        status = "PASSED"
        failure_reason = ""
        
        if report.failed:
            status = "FAILED"
            failure_reason = str(report.longreprtext).splitlines()[-1] if report.longreprtext else "Assertion Error"
            # Capture screenshot if driver available
            driver_inst = item.funcargs.get("driver")
            if driver_inst:
                capture_screenshot(driver_inst, item.name)
        elif report.skipped:
            status = "SKIPPED"
            failure_reason = getattr(report, "wasxfail", "Skipped by test runner")

        RESULTS_COLLECTION.append({
            "test_id": test_id,
            "module": module,
            "test_name": item.name,
            "priority": priority,
            "execution_time": duration,
            "status": status,
            "failure_reason": failure_reason
        })

def pytest_sessionfinish(session, exitstatus):
    global START_TIME
    total_duration = time.time() - START_TIME
    
    from automation.utils.excel_reporter import ExcelReporter
    from automation.utils.html_reporter import HTMLReporter
    from automation.utils.summary_generator import SummaryGenerator
    
    logger.info(f"Test Execution completed. Total collected results: {len(RESULTS_COLLECTION)}")
    ExcelReporter.generate_excel_reports(RESULTS_COLLECTION)
    HTMLReporter.generate_html_reports(RESULTS_COLLECTION)
    SummaryGenerator.generate_summary(RESULTS_COLLECTION, total_duration)
