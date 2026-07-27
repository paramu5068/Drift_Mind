import os
from pathlib import Path

class Config:
    # Base Application URL - Default to GitHub Pages Live URL
    BASE_URL = os.getenv("BASE_URL", "https://paramu5068.github.io/Drift_Mind/")
    
    # Browser Settings
    BROWSER = os.getenv("BROWSER", "chrome").lower()
    HEADLESS = os.getenv("HEADLESS", "true").lower() == "true"
    WINDOW_WIDTH = int(os.getenv("WINDOW_WIDTH", "1920"))
    WINDOW_HEIGHT = int(os.getenv("WINDOW_HEIGHT", "1080"))
    
    # Timeouts (seconds)
    IMPLICIT_WAIT = int(os.getenv("IMPLICIT_WAIT", "10"))
    EXPLICIT_WAIT = int(os.getenv("EXPLICIT_WAIT", "15"))
    PAGE_LOAD_TIMEOUT = int(os.getenv("PAGE_LOAD_TIMEOUT", "30"))
    
    # Retry & Execution Config
    MAX_RETRIES = int(os.getenv("MAX_RETRIES", "2"))
    PARALLEL_WORKERS = os.getenv("PARALLEL_WORKERS", "auto")
    
    # Base Directories
    BASE_DIR = Path(__file__).resolve().parent.parent.parent
    AUTOMATION_DIR = BASE_DIR / "automation"
    OUTPUT_DIR = BASE_DIR / "Test Results"
    
    # Report Directories
    EXCEL_DIR = OUTPUT_DIR / "Excel"
    HTML_DIR = OUTPUT_DIR / "HTML"
    SCREENSHOTS_DIR = OUTPUT_DIR / "Screenshots"
    LOGS_DIR = OUTPUT_DIR / "Logs"
    JSON_DIR = OUTPUT_DIR / "JSON"
    SUMMARY_DIR = OUTPUT_DIR / "Summary"
    
    @classmethod
    def ensure_directories(cls):
        """Ensure all output report directories exist."""
        for directory in [
            cls.OUTPUT_DIR,
            cls.EXCEL_DIR,
            cls.HTML_DIR,
            cls.SCREENSHOTS_DIR,
            cls.LOGS_DIR,
            cls.JSON_DIR,
            cls.SUMMARY_DIR,
        ]:
            directory.mkdir(parents=True, exist_ok=True)

Config.ensure_directories()
