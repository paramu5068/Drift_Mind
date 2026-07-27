from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class HomePage(BasePage):
    TITLE_HEADER = (By.XPATH, "//h1 | //title | //head/title")
    CANVAS_ELEMENT = (By.TAG_NAME, "canvas")
    FLUTTER_VIEW = (By.TAG_NAME, "flutter-view")

    def is_app_loaded(self) -> bool:
        has_canvas = len(self.find_elements(*self.CANVAS_ELEMENT)) > 0
        has_flutter = len(self.find_elements(*self.FLUTTER_VIEW)) > 0
        has_body = len(self.find_elements(By.TAG_NAME, "body")) > 0
        return has_canvas or has_flutter or has_body
