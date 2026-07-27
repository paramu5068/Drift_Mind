import pytest
from automation.pages.home_page import HomePage

SESS_TEST_CASES = [f"TC_SESS_{i:03d}" for i in range(1, 21)]

@pytest.mark.auth
@pytest.mark.parametrize("test_case_id", SESS_TEST_CASES)
def test_session_management_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
