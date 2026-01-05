/**
 * Health Check API Test
 * 
 * Test base per verificare che l'endpoint di health check
 * risponda correttamente. Questo test è eseguito nella pipeline CI/CD.
 */

describe('Health Check API', () => {
  const HEALTH_ENDPOINT = process.env.TEST_URL || 'http://localhost:3000';

  it('should return 200 status code', async () => {
    const response = await fetch(`${HEALTH_ENDPOINT}/api/health`);
    expect(response.status).toBe(200);
  });

  it('should return healthy status', async () => {
    const response = await fetch(`${HEALTH_ENDPOINT}/api/health`);
    const data = await response.json();
    
    expect(data).toHaveProperty('status');
    expect(data.status).toBe('healthy');
  });

  it('should return database connection status', async () => {
    const response = await fetch(`${HEALTH_ENDPOINT}/api/health`);
    const data = await response.json();
    
    expect(data).toHaveProperty('database');
    expect(['connected', 'disconnected']).toContain(data.database);
  });

  it('should return JSON content type', async () => {
    const response = await fetch(`${HEALTH_ENDPOINT}/api/health`);
    const contentType = response.headers.get('content-type');
    
    expect(contentType).toContain('application/json');
  });

  it('should respond within 2 seconds', async () => {
    const startTime = Date.now();
    await fetch(`${HEALTH_ENDPOINT}/api/health`);
    const endTime = Date.now();
    
    const responseTime = endTime - startTime;
    expect(responseTime).toBeLessThan(2000);
  });
});
