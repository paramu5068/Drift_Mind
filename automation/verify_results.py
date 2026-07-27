import os
import json

def verify_results():
    results_file = "Test Results/JSON/execution-results.json"
    if not os.path.exists(results_file):
        print("Results file not found!")
        exit(1)
        
    with open(results_file, "r") as f:
        tests = json.load(f)
        
    total = len(tests)
    passed = len([t for t in tests if t["Status"] == "Pass"])
    
    pass_rate = (passed / total) * 100
    print(f"Pass Rate: {pass_rate:.2f}%")
    
    if pass_rate < 95.0:
        print("Pass rate below 95%. Failing the pipeline.")
        exit(1)
    else:
        print("Pass rate is acceptable.")
        exit(0)

if __name__ == "__main__":
    verify_results()
