from flask import Flask, render_template
import json
import os

app = Flask(__name__)

def get_scan_status():
    try:
        if os.path.exists('trivy-report.json'):
            with open('trivy-report.json', 'r') as f:
                report = json.load(f)
                results = report.get('Results', [])
                vulnerabilities = []
                for result in results:
                    if 'Vulnerabilities' in result:
                        vulnerabilities.extend(result['Vulnerabilities'])
                high_critical = [v for v in vulnerabilities if v.get('Severity') in ['HIGH', 'CRITICAL']]
                return {
                    'status': '⚠️ Issues Found' if high_critical else '✅ Secure',
                    'count': len(high_critical),
                    'details': high_critical[:5]  # Show top 5 for brevity
                }
        return {'status': 'Scan Not Available', 'count': 0, 'details': []}
    except Exception as e:
        return {'status': f'Error: {str(e)}', 'count': 0, 'details': []}

@app.route('/')
def home():
    scan_data = get_scan_status()
    return render_template('index.html', scan_data=scan_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)