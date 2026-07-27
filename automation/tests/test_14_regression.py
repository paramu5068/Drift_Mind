import pytest
from automation.pages.home_page import HomePage

REG_TEST_CASES = [f"TC_REG_{i:03d}" for i in range(1, 51)]

@pytest.mark.regression
@pytest.mark.parametrize("test_case_id", REG_TEST_CASES)
def test_regression_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
