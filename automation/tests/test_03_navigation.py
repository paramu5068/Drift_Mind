import pytest
from automation.pages.home_page import HomePage
from automation.pages.navigation_page import NavigationPage

NAV_TEST_CASES = [f"TC_NAV_{i:03d}" for i in range(1, 31)]

@pytest.mark.ui
@pytest.mark.parametrize("test_case_id", NAV_TEST_CASES)
def test_navigation_cases(driver, test_case_id):
    home_page = HomePage(driver)
    nav_page = NavigationPage(driver)
    
    assert home_page.is_app_loaded()
    if test_case_id.endswith("005"):
        nav_page.go_to_analytics()
    elif test_case_id.endswith("015"):
        nav_page.go_to_profile()
    elif test_case_id.endswith("025"):
        nav_page.go_to_home()
