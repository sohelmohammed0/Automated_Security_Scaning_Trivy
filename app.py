from flask import Flask, render_template
import json
import os
import time

app = Flask(__name__)

def get_scan_status():
    report_path = '/app/trivy-report.json'
    app.logger.info(f"Checking for report at: {report_path}")
    
    if not os.path.exists(report_path):
        app.logger.warning(f"Report file not found at {report_path}")
        return {'status': 'Scan Not Available', 'count': 0, 'details': [], 'timestamp': 'N/A'}
    
    try:
        with open(report_path, 'r') as f:
            content = f.read().strip()
            if not content:
                app.logger.warning("Report file is empty")
                return {'status': 'Empty Report', 'count': 0, 'details': [], 'timestamp': 'N/A'}
            
            report = json.loads(content)
            app.logger.info("Report loaded successfully")
            
            results = report.get('Results', [])
            vulnerabilities = []
            for result in results:
                if 'Vulnerabilities' in result:
                    vulnerabilities.extend(result['Vulnerabilities'])
            
            high_critical = [v for v in vulnerabilities if v.get('Severity') in ['HIGH', 'CRITICAL']]
            status = '⚠️ Issues Found' if high_critical else '✅ Secure'
            app.logger.info(f"Scan status: {status}, Issues: {len(high_critical)}")
            
            return {
                'status': status,
                'count': len(high_critical),
                'details': high_critical[:5],
                'timestamp': time.ctime(os.path.getmtime(report_path))
            }
    except json.JSONDecodeError as e:
        app.logger.error(f"JSON parsing error: {str(e)}")
        return {'status': f'Error: Invalid JSON ({str(e)})', 'count': 0, 'details': [], 'timestamp': 'N/A'}
    except Exception as e:
        app.logger.error(f"Unexpected error: {str(e)}")
        return {'status': f'Error: {str(e)}', 'count': 0, 'details': [], 'timestamp': 'N/A'}

@app.route('/')
def home():
    scan_data = get_scan_status()
    return render_template('index.html', scan_data=scan_data)

# Log startup status
with app.app_context():
    get_scan_status()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)