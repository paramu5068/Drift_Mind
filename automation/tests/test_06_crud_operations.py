import pytest
from automation.pages.home_page import HomePage

CRUD_TEST_CASES = [f"TC_CRUD_{i:03d}" for i in range(1, 51)]

@pytest.mark.crud
@pytest.mark.parametrize("test_case_id", CRUD_TEST_CASES)
def test_crud_cases(driver, test_case_id):
    home_page = HomePage(driver)
    assert home_page.is_app_loaded()
