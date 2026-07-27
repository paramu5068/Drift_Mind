import pytest
from automation.pages.home_page import HomePage

FORM_TEST_CASES = [f"TC_FORM_{i:03d}" for i in range(1, 51)]

@pytest.mark.forms
@pytest.mark.parametrize("test_case_id", FORM_TEST_CASES)
def test_form_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
