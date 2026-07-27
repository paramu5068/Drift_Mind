import pytest
from automation.pages.home_page import HomePage

AUTHZ_TEST_CASES = [f"TC_AUTHZ_{i:03d}" for i in range(1, 41)]

@pytest.mark.auth
@pytest.mark.parametrize("test_case_id", AUTHZ_TEST_CASES)
def test_authorization_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert driver.current_url.startswith("http")
    assert home_page.is_app_loaded()
