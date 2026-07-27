import time
import logging
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from automation.config.config import Config

logger = logging.getLogger(__name__)

class BasePage:
    def __init__(self, driver: WebDriver):
        self.driver = driver
        self.wait = WebDriverWait(driver, Config.EXPLICIT_WAIT)

    def navigate_to(self, path: str = ""):
        target_url = Config.BASE_URL.rstrip('/') + '/' + path.lstrip('/')
        logger.info(f"Navigating to: {target_url}")
        self.driver.get(target_url)

    def get_current_url(self) -> str:
        return self.driver.current_url

    def get_title(self) -> str:
        return self.driver.title

    def find_element(self, by: By, value: str, timeout: int = None) -> WebElement:
        wait = WebDriverWait(self.driver, timeout or Config.EXPLICIT_WAIT)
        return wait.until(EC.presence_of_element_located((by, value)))

    def find_elements(self, by: By, value: str):
        return self.driver.find_elements(by, value)

    def click(self, by: By, value: str):
        element = self.wait.until(EC.element_to_be_clickable((by, value)))
        element.click()

    def send_keys(self, by: By, value: str, text: str):
        element = self.find_element(by, value)
        element.clear()
        element.send_keys(text)

    def get_text(self, by: By, value: str) -> str:
        element = self.find_element(by, value)
        return element.text

    def is_displayed(self, by: By, value: str) -> bool:
        try:
            return self.find_element(by, value).is_displayed()
        except Exception:
            return False

    def wait_for_flutter(self, timeout: int = 15):
        """Wait for Flutter web app canvas/DOM bootstrap to render."""
        start_time = time.time()
        while time.time() - start_time < timeout:
            body_text = self.driver.find_element(By.TAG_NAME, "body").text
            canvas = self.driver.find_elements(By.TAG_NAME, "canvas")
            flutter_view = self.driver.find_elements(By.TAG_NAME, "flutter-view")
            if canvas or flutter_view or body_text:
                return True
            time.sleep(0.5)
        return False
