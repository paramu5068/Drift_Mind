from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class NavigationPage(BasePage):
    HOME_TAB = (By.XPATH, "//a[contains(@href,'home') or contains(text(),'Home')]")
    ANALYTICS_TAB = (By.XPATH, "//a[contains(@href,'analytics') or contains(text(),'Analytics')]")
    INSIGHTS_TAB = (By.XPATH, "//a[contains(@href,'insights') or contains(text(),'Insights')]")
    PROFILE_TAB = (By.XPATH, "//a[contains(@href,'profile') or contains(text(),'Profile')]")

    def go_to_home(self):
        if self.is_displayed(*self.HOME_TAB):
            self.click(*self.HOME_TAB)

    def go_to_analytics(self):
        if self.is_displayed(*self.ANALYTICS_TAB):
            self.click(*self.ANALYTICS_TAB)

    def go_to_profile(self):
        if self.is_displayed(*self.PROFILE_TAB):
            self.click(*self.PROFILE_TAB)
