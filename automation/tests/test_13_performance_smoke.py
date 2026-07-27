import pytest
import time
from automation.pages.home_page import HomePage

PERF_TEST_CASES = [f"TC_PERF_{i:03d}" for i in range(1, 21)]

@pytest.mark.performance
@pytest.mark.parametrize("test_case_id", PERF_TEST_CASES)
def test_performance_smoke_cases(driver, test_case_id):
    start = time.time()
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
    elapsed = time.time() - start
    assert elapsed < 10.0
