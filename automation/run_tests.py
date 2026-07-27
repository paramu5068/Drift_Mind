import sys
import subprocess
import os
from pathlib import Path

def main():
    print("=" * 60)
    print("Starting Drift Mind Live E2E Selenium Automation Suite")
    print("=" * 60)
    
    base_dir = Path(__file__).resolve().parent
    root_dir = base_dir.parent
    
    # Run PyTest
    cmd = [
        sys.executable,
        "-m",
        "pytest",
        str(base_dir / "tests"),
        "-c",
        str(base_dir / "pytest.ini"),
        "-o",
        f"pythonpath={root_dir}"
    ]
    
    print(f"Executing command: {' '.join(cmd)}")
    result = subprocess.run(cmd)
    
    print("=" * 60)
    print(f"Test Execution Completed with return code: {result.returncode}")
    print("=" * 60)
    sys.exit(result.returncode)

if __name__ == "__main__":
    main()
