import logging
import sys
from automation.config.config import Config

def setup_logger(name: str = "automation"):
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    
    if not logger.handlers:
        # File handler
        log_file = Config.LOGS_DIR / "automation.log"
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_formatter = logging.Formatter(
            "[%(asctime)s] [%(levelname)s] [%(name)s]: %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S"
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
        
        # Console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_formatter = logging.Formatter("[%(levelname)s] %(message)s")
        console_handler.setFormatter(console_formatter)
        logger.addHandler(console_handler)
        
    return logger

logger = setup_logger()
