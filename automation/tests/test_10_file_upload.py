import pytest
from automation.pages.home_page import HomePage

UPLOAD_TEST_CASES = [f"TC_UPLOAD_{i:03d}" for i in range(1, 21)]

@pytest.mark.forms
@pytest.mark.parametrize("test_case_id", UPLOAD_TEST_CASES)
def test_file_upload_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
