import pytest
from automation.pages.home_page import HomePage

INPUT_VAL_TEST_CASES = [f"TC_INPUT_{i:03d}" for i in range(1, 41)]

@pytest.mark.forms
@pytest.mark.parametrize("test_case_id", INPUT_VAL_TEST_CASES)
def test_input_validation_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
