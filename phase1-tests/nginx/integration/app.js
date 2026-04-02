// Simple interactive API testing for the integration test

async function checkHealth() {
    const resultDiv = document.getElementById('health-result');

    try {
        const response = await fetch('/health');
        const text = await response.text();

        resultDiv.textContent = `Response: ${text}`;
        resultDiv.className = 'result success';
    } catch (error) {
        resultDiv.textContent = `Error: ${error.message}`;
        resultDiv.className = 'result error';
    }
}

async function checkStatus() {
    const resultDiv = document.getElementById('status-result');

    try {
        const response = await fetch('/api/status');
        const data = await response.json();

        resultDiv.textContent = JSON.stringify(data, null, 2);
        resultDiv.className = 'result success';
    } catch (error) {
        resultDiv.textContent = `Error: ${error.message}`;
        resultDiv.className = 'result error';
    }
}

// Log when page loads
console.log('Hummingbird nginx Integration Test loaded successfully');
