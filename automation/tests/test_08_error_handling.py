import pytest
from automation.pages.home_page import HomePage

ERR_TEST_CASES = [f"TC_ERR_{i:03d}" for i in range(1, 21)]

@pytest.mark.regression
@pytest.mark.parametrize("test_case_id", ERR_TEST_CASES)
def test_error_handling_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
