from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class ProfilePage(BasePage):
    THEME_TOGGLE = (By.XPATH, "//button[contains(text(),'Theme') or contains(@aria-label,'theme')]")
    CLEAR_DATA_BUTTON = (By.XPATH, "//button[contains(text(),'Clear') or contains(text(),'Reset')]")

    def toggle_theme(self):
        if self.is_displayed(*self.THEME_TOGGLE):
            self.click(*self.THEME_TOGGLE)

    def clear_data(self):
        if self.is_displayed(*self.CLEAR_DATA_BUTTON):
            self.click(*self.CLEAR_DATA_BUTTON)
