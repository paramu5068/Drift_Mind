from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class AuthPage(BasePage):
    USERNAME_FIELD = (By.XPATH, "//input[@type='email' or @type='text' or @aria-label='Email']")
    PASSWORD_FIELD = (By.XPATH, "//input[@type='password' or @aria-label='Password']")
    LOGIN_BUTTON = (By.XPATH, "//button[contains(text(),'Login') or contains(text(),'Sign In')]")
    SIGNUP_BUTTON = (By.XPATH, "//button[contains(text(),'Sign Up') or contains(text(),'Register')]")
    LOGOUT_BUTTON = (By.XPATH, "//button[contains(text(),'Logout')]")

    def login(self, username: str, password: str):
        if self.is_displayed(*self.USERNAME_FIELD):
            self.send_keys(*self.USERNAME_FIELD, username)
            self.send_keys(*self.PASSWORD_FIELD, password)
            self.click(*self.LOGIN_BUTTON)

    def signup(self, username: str, password: str):
        if self.is_displayed(*self.USERNAME_FIELD):
            self.send_keys(*self.USERNAME_FIELD, username)
            self.send_keys(*self.PASSWORD_FIELD, password)
            self.click(*self.SIGNUP_BUTTON)

    def is_logged_in(self) -> bool:
        return self.is_displayed(*self.LOGOUT_BUTTON)
