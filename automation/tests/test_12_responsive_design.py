import pytest
from automation.pages.home_page import HomePage

RESP_TEST_CASES = [f"TC_RESP_{i:03d}" for i in range(1, 21)]

@pytest.mark.ui
@pytest.mark.parametrize("test_case_id", RESP_TEST_CASES)
def test_responsive_design_cases(driver, test_case_id):
    home_page = HomePage(driver)
    if test_case_id.endswith("001"):
        driver.set_window_size(375, 812) # Mobile
    elif test_case_id.endswith("010"):
        driver.set_window_size(768, 1024) # Tablet
    elif test_case_id.endswith("020"):
        driver.set_window_size(1920, 1080) # Desktop
        
    assert home_page.is_app_loaded()
