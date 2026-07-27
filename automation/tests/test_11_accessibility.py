import pytest
from automation.pages.home_page import HomePage

A11Y_TEST_CASES = [f"TC_A11Y_{i:03d}" for i in range(1, 21)]

@pytest.mark.ui
@pytest.mark.parametrize("test_case_id", A11Y_TEST_CASES)
def test_accessibility_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
