import datetime
from pathlib import Path
from selenium.webdriver.remote.webdriver import WebDriver
from automation.config.config import Config
from automation.utils.logger import logger

def capture_screenshot(driver: WebDriver, test_name: str) -> str:
    """Capture screenshot on test failure or on demand."""
    try:
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        clean_test_name = "".join([c if c.isalnum() else "_" for c in test_name])
        filename = f"{clean_test_name}_{timestamp}.png"
        filepath = Config.SCREENSHOTS_DIR / filename
        
        driver.save_screenshot(str(filepath))
        logger.info(f"Screenshot saved: {filepath}")
        return str(filepath)
    except Exception as e:
        logger.error(f"Failed to capture screenshot for {test_name}: {e}")
        return ""
