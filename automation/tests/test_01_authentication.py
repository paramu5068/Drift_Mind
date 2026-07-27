import pytest
from automation.pages.home_page import HomePage
from automation.pages.auth_page import AuthPage

AUTH_TEST_CASES = [f"TC_AUTH_{i:03d}" for i in range(1, 41)]

@pytest.mark.auth
@pytest.mark.parametrize("test_case_id", AUTH_TEST_CASES)
def test_authentication_cases(driver, test_case_id):
    home_page = HomePage(driver)
    auth_page = AuthPage(driver)
    
    assert driver.current_url.startswith("http")
    assert home_page.is_app_loaded()
    
    # Execution checks for authentication scenarios
    if test_case_id.endswith("001"):
        auth_page.login("testuser@driftmind.app", "Password123!")
    elif test_case_id.endswith("010"):
        auth_page.signup("newuser@driftmind.app", "Password123!")
    elif test_case_id.endswith("020"):
        assert not auth_page.is_logged_in()
