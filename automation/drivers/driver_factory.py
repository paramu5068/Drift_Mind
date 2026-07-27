from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.chrome.service import Service as ChromeService
from automation.config.config import Config
import logging

logger = logging.getLogger(__name__)

class DriverFactory:
    @staticmethod
    def create_driver(browser_name: str = None, headless: bool = None):
        browser = (browser_name or Config.BROWSER).lower()
        is_headless = Config.HEADLESS if headless is None else headless

        if browser == "chrome":
            options = ChromeOptions()
            if is_headless:
                options.add_argument("--headless=new")
            options.add_argument("--no-sandbox")
            options.add_argument("--disable-dev-shm-usage")
            options.add_argument("--disable-gpu")
            options.add_argument("--disable-extensions")
            options.add_argument(f"--window-size={Config.WINDOW_WIDTH},{Config.WINDOW_HEIGHT}")
            options.add_argument("--ignore-certificate-errors")
            options.add_argument("--allow-running-insecure-content")
            options.set_capability("goog:loggingPrefs", {"browser": "ALL"})
            
            driver = webdriver.Chrome(options=options)
            driver.set_page_load_timeout(Config.PAGE_LOAD_TIMEOUT)
            driver.implicitly_wait(Config.IMPLICIT_WAIT)
            return driver
        else:
            raise ValueError(f"Unsupported browser: {browser}")
