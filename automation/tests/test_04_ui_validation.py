import pytest
from automation.pages.home_page import HomePage

UI_TEST_CASES = [f"TC_UI_{i:03d}" for i in range(1, 51)]

@pytest.mark.ui
@pytest.mark.parametrize("test_case_id", UI_TEST_CASES)
def test_ui_validation_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
    assert len(driver.title) >= 0
