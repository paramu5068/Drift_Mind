import json
import datetime
from jinja2 import Template
from automation.config.config import Config
from automation.utils.logger import logger
from typing import List, Dict

class HTMLReporter:
    HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Automation Test Execution Dashboard - Drift Mind</title>
    <style>
        :root {
            --bg-color: #0f172a;
            --card-bg: #1e293b;
            --text-color: #f8fafc;
            --text-secondary: #94a3b8;
            --accent-pass: #10b981;
            --accent-fail: #ef4444;
            --accent-skip: #f59e0b;
            --primary-blue: #3b82f6;
            --border-color: #334155;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            margin: 0;
            padding: 24px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 20px;
            margin-bottom: 24px;
        }

        .header h1 {
            margin: 0;
            font-size: 24px;
            color: #38bdf8;
        }

        .badge-live {
            background-color: rgba(16, 185, 129, 0.2);
            color: var(--accent-pass);
            border: 1px solid var(--accent-pass);
            padding: 4px 12px;
            border-radius: 9999px;
            font-size: 13px;
            font-weight: 600;
        }

        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 32px;
        }

        .card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
        }

        .card .value {
            font-size: 32px;
            font-weight: 700;
            margin-top: 8px;
        }

        .card.pass .value { color: var(--accent-pass); }
        .card.fail .value { color: var(--accent-fail); }
        .card.skip .value { color: var(--accent-skip); }
        .card.total .value { color: var(--primary-blue); }

        .table-container {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            overflow: hidden;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        th, td {
            padding: 14px 18px;
            border-bottom: 1px solid var(--border-color);
        }

        th {
            background-color: #0f172a;
            color: var(--text-secondary);
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        tr:hover {
            background-color: rgba(255, 255, 255, 0.02);
        }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
        }

        .status-PASSED { background-color: rgba(16, 185, 129, 0.2); color: var(--accent-pass); }
        .status-FAILED { background-color: rgba(239, 68, 68, 0.2); color: var(--accent-fail); }
        .status-SKIPPED { background-color: rgba(245, 158, 11, 0.2); color: var(--accent-skip); }

        .footer {
            margin-top: 32px;
            text-align: center;
            color: var(--text-secondary);
            font-size: 13px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>Live GitHub Pages E2E Execution Dashboard</h1>
            <p style="color: var(--text-secondary); margin: 6px 0 0 0;">Target URL: <a href="{{ base_url }}" target="_blank" style="color: #38bdf8; text-decoration: none;">{{ base_url }}</a></p>
        </div>
        <div class="badge-live">LIVE DEPLOYMENT VERIFIED</div>
    </div>

    <div class="cards-grid">
        <div class="card total">
            <div style="color: var(--text-secondary); font-size: 14px;">Total Test Cases</div>
            <div class="value">{{ total }}</div>
        </div>
        <div class="card pass">
            <div style="color: var(--text-secondary); font-size: 14px;">Passed</div>
            <div class="value">{{ passed }}</div>
        </div>
        <div class="card fail">
            <div style="color: var(--text-secondary); font-size: 14px;">Failed</div>
            <div class="value">{{ failed }}</div>
        </div>
        <div class="card skip">
            <div style="color: var(--text-secondary); font-size: 14px;">Skipped</div>
            <div class="value">{{ skipped }}</div>
        </div>
        <div class="card">
            <div style="color: var(--text-secondary); font-size: 14px;">Success Rate</div>
            <div class="value" style="color: #38bdf8;">{{ pass_rate }}%</div>
        </div>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Test ID</th>
                    <th>Module</th>
                    <th>Test Name</th>
                    <th>Priority</th>
                    <th>Duration (s)</th>
                    <th>Status</th>
                    <th>Failure / Details</th>
                </tr>
            </thead>
            <tbody>
                {% for test in tests %}
                <tr>
                    <td><code>{{ test.test_id }}</code></td>
                    <td>{{ test.module }}</td>
                    <td>{{ test.test_name }}</td>
                    <td><span style="color: #cbd5e1;">{{ test.priority }}</span></td>
                    <td>{{ test.execution_time }}s</td>
                    <td><span class="status-badge status-{{ test.status }}">{{ test.status }}</span></td>
                    <td style="color: #94a3b8; font-size: 13px;">{{ test.failure_reason or '-' }}</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>

    <div class="footer">
        Generated on {{ timestamp }} | Drift Mind Automated Live E2E Verification Engine
    </div>
</body>
</html>
"""

    @staticmethod
    def generate_html_reports(test_results: List[Dict]):
        """Generate execution-report.html and dashboard.html."""
        total = len(test_results)
        passed = sum(1 for t in test_results if t["status"] == "PASSED")
        failed = sum(1 for t in test_results if t["status"] == "FAILED")
        skipped = sum(1 for t in test_results if t["status"] == "SKIPPED")
        pass_rate = round((passed / total * 100), 2) if total > 0 else 0
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")

        template = Template(HTMLReporter.HTML_TEMPLATE)
        html_content = template.render(
            base_url=Config.BASE_URL,
            total=total,
            passed=passed,
            failed=failed,
            skipped=skipped,
            pass_rate=pass_rate,
            tests=test_results,
            timestamp=timestamp
        )

        exec_report = Config.HTML_DIR / "execution-report.html"
        dashboard_report = Config.HTML_DIR / "dashboard.html"

        exec_report.write_text(html_content, encoding="utf-8")
        dashboard_report.write_text(html_content, encoding="utf-8")

        # Save JSON output
        json_report = Config.JSON_DIR / "execution-results.json"
        json_report.write_text(json.dumps({
            "timestamp": timestamp,
            "base_url": Config.BASE_URL,
            "metrics": {
                "total": total,
                "passed": passed,
                "failed": failed,
                "skipped": skipped,
                "pass_rate": pass_rate
            },
            "results": test_results
        }, indent=2), encoding="utf-8")

        logger.info(f"HTML & JSON reports generated in {Config.HTML_DIR} and {Config.JSON_DIR}")
