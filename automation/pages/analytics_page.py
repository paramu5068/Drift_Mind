from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class AnalyticsPage(BasePage):
    CHART_CANVAS = (By.XPATH, "//canvas")
    FILTER_BUTTON = (By.XPATH, "//button[contains(text(),'Filter') or contains(text(),'Date')]")

    def is_chart_visible(self) -> bool:
        return len(self.find_elements(*self.CHART_CANVAS)) > 0
