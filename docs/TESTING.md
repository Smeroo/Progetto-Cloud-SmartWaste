# SmartWaste - Testing & Validation Guide

This document provides comprehensive testing instructions to validate the cloud-native implementation of SmartWaste.

## Table of Contents
1. [Pre-Testing Checklist](#pre-testing-checklist)
2. [Docker Build Testing](#docker-build-testing)
3. [Docker Compose Testing](#docker-compose-testing)
4. [Database Persistence Testing](#database-persistence-testing)
5. [Application Functionality Testing](#application-functionality-testing)
6. [CI/CD Pipeline Testing](#cicd-pipeline-testing)
7. [Security Testing](#security-testing)
8. [Performance Testing](#performance-testing)

---

## Pre-Testing Checklist

Before starting tests, ensure you have:

- [ ] Docker installed (version 24.0+)
- [ ] Docker Compose installed (version 2.20+)
- [ ] At least 8GB RAM available
- [ ] At least 10GB free disk space
- [ ] Git repository cloned locally
- [ ] No other services running on ports 3000, 5432

### Check Prerequisites

```bash
# Check Docker version
docker --version
# Expected: Docker version 24.0 or higher

# Check Docker Compose version
docker-compose --version
# Expected: Docker Compose version 2.20 or higher

# Check available disk space
df -h
# Ensure at least 10GB free

# Check if ports are available
lsof -i :3000
lsof -i :5432
# Should return nothing (ports free)
```

---

## Docker Build Testing

### Test 1: Dockerfile Syntax Validation

```bash
cd /path/to/Progetto-Cloud-SmartWaste

# Validate Dockerfile syntax
docker build --check .
```

**Expected Result:** No syntax errors

### Test 2: Build Docker Image (No Cache)

```bash
# Build from scratch without cache
docker build --no-cache -t smartwaste:test .
```

**Expected Results:**
- ✅ All stages complete successfully
- ✅ Build completes in 5-10 minutes (first time)
- ✅ Final image created

**Check:**
```bash
# Verify image exists
docker images | grep smartwaste

# Check image size (should be < 500MB)
docker images smartwaste:test --format "{{.Size}}"
```

### Test 3: Image Security Scan

```bash
# Scan for vulnerabilities (using Trivy)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image smartwaste:test
```

**Expected Result:** No critical vulnerabilities in application code

### Test 4: Verify Non-Root User

```bash
# Check that container runs as non-root
docker run --rm smartwaste:test whoami
```

**Expected Result:** `nextjs` (not `root`)

---

## Docker Compose Testing

### Test 5: Docker Compose Configuration Validation

```bash
# Validate docker-compose.yml syntax
docker-compose config
```

**Expected Result:** Valid YAML configuration printed

### Test 6: Complete Setup from Scratch

```bash
# Clean environment
docker-compose down -v
docker system prune -af

# Run setup script
./scripts/setup.sh
```

**Expected Results:**
- ✅ `.env` file created with generated secrets
- ✅ Docker images built successfully
- ✅ Containers started (database, frontend)
- ✅ Database migrations completed
- ✅ Database seeded with demo data
- ✅ Health check passes

**Verification:**
```bash
# Check container status
docker-compose ps
# Both containers should be "Up" and "healthy"

# Check logs
docker-compose logs --tail=50

# Test health endpoint
curl http://localhost:3000/api/health
# Expected: {"status":"healthy","database":"connected"}
```

### Test 7: Service Dependencies

```bash
# Stop frontend only
docker-compose stop frontend

# Database should still be running
docker-compose ps

# Restart frontend
docker-compose start frontend

# Should reconnect to database automatically
sleep 10
curl http://localhost:3000/api/health
```

**Expected Result:** Frontend reconnects to database successfully

### Test 8: Resource Limits

```bash
# Check resource usage
docker stats --no-stream

# Verify limits are enforced
docker inspect smartwaste-app | grep -A 10 Resources
docker inspect smartwaste-db | grep -A 10 Resources
```

**Expected Results:**
- Frontend: CPU limit 2.0, Memory limit 1GB
- Database: CPU limit 1.0, Memory limit 512MB

---

## Database Persistence Testing

### Test 9: Data Persistence After Container Restart

```bash
# 1. Access the application
open http://localhost:3000

# 2. Login with demo account
# Email: admin@smartwaste.demo
# Password: Demo123!

# 3. Create some test data (collection points, reports, etc.)

# 4. Stop containers
docker-compose down

# 5. Verify volume still exists
docker volume ls | grep smartwaste

# 6. Restart containers
docker-compose up -d

# 7. Wait for startup
sleep 20

# 8. Login again and verify data is still present
open http://localhost:3000
```

**Expected Result:** All data created in step 3 is still present

### Test 10: Volume Backup and Restore

```bash
# Backup volume
docker run --rm \
  -v smartwaste_postgres_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/smartwaste-backup.tar.gz /data

# Destroy volume
docker-compose down -v

# Restore volume
docker volume create smartwaste_postgres_data
docker run --rm \
  -v smartwaste_postgres_data:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd / && tar xzf /backup/smartwaste-backup.tar.gz"

# Start containers
docker-compose up -d

# Verify data restored
sleep 20
curl http://localhost:3000/api/health
```

**Expected Result:** Data restored successfully

---

## Application Functionality Testing

### Test 11: User Authentication

```bash
# Test login API
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@smartwaste.demo",
    "password": "Demo123!"
  }'
```

**Expected Result:** Successful authentication with session token

### Test 12: API Endpoints

```bash
# Health check
curl http://localhost:3000/api/health
# Expected: {"status":"healthy"}

# Collection points (should require auth)
curl http://localhost:3000/api/collection-points
# Expected: JSON array or 401 Unauthorized

# Map data
curl http://localhost:3000/api/map
# Expected: JSON data for map
```

### Test 13: Database Queries

```bash
# Access database directly
docker-compose exec database psql -U smartwaste_user -d smartwaste

# Run test queries
SELECT COUNT(*) FROM "User";
SELECT COUNT(*) FROM "CollectionPoint";
SELECT COUNT(*) FROM "WasteType";

# Exit
\q
```

**Expected Results:**
- Users: At least 6 (including demo accounts)
- CollectionPoints: Multiple entries
- WasteTypes: Several waste types

### Test 14: Frontend Accessibility

```bash
# Test main page loads
curl -I http://localhost:3000
# Expected: HTTP 200 OK

# Test static assets
curl -I http://localhost:3000/favicon.ico
# Expected: HTTP 200 OK or 404 (depends on setup)

# Open in browser for manual testing
open http://localhost:3000
```

**Manual Testing Checklist:**
- [ ] Home page loads correctly
- [ ] Login page accessible
- [ ] Map displays properly (with Leaflet)
- [ ] Navigation works
- [ ] No console errors (check browser DevTools)

---

## CI/CD Pipeline Testing

### Test 15: GitHub Actions Workflow Validation

```bash
# Validate workflow syntax locally (requires act)
act --dryrun
```

**Or check on GitHub:**
1. Push changes to GitHub
2. Go to Actions tab
3. Check workflow runs

**Expected Results:**
- ✅ Build stage completes
- ✅ Test stage completes
- ✅ Security stage completes (warnings OK)
- ✅ Docker image pushed to GHCR (on main branch)

### Test 16: Local Build Simulation

```bash
# Simulate CI build locally
npm ci
npm run build
npm run lint
npx prisma validate
```

**Expected Results:**
- Dependencies install successfully
- Build completes (with possible warnings)
- Linting passes (minor warnings OK)
- Prisma schema valid

---

## Security Testing

### Test 17: Secret Detection

```bash
# Check for accidentally committed secrets
grep -r "password\|secret\|token\|key" .env 2>/dev/null
# Should only show .env.example files, not real .env

# Verify .env is in .gitignore
git check-ignore .env
# Expected: .env (means it's ignored)
```

### Test 18: Container Security

```bash
# Check for running processes as root
docker-compose exec frontend ps aux | grep root
# Should only show system processes, not the Node app

# Check file permissions
docker-compose exec frontend ls -la /app
# Files should be owned by nextjs:nodejs (uid 1001)
```

### Test 19: Network Isolation

```bash
# Check network configuration
docker network inspect smartwaste_network

# Verify only exposed ports are accessible
nmap localhost -p 1-9999 | grep open
# Should only show 3000, 5432 (and SSH if enabled)
```

### Test 20: SQL Injection Prevention

Test that Prisma ORM prevents SQL injection:

```bash
# Try SQL injection in login
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@smartwaste.demo",
    "password": "Demo123! OR 1=1--"
  }'
```

**Expected Result:** Authentication fails (not bypassed)

---

## Performance Testing

### Test 21: Startup Time

```bash
# Stop containers
docker-compose down

# Measure startup time
time docker-compose up -d
# Wait for healthy status
docker-compose ps

# Check how long until healthy
docker-compose logs frontend | grep "ready"
```

**Expected Results:**
- Container start: < 10 seconds
- Health check pass: < 40 seconds
- Total startup: < 60 seconds

### Test 22: Response Time

```bash
# Install Apache Bench (if not installed)
# sudo apt-get install apache2-utils  # Linux
# brew install apache2  # macOS

# Test response times
ab -n 100 -c 10 http://localhost:3000/api/health

# Check results
# Look for "Requests per second" and "Time per request"
```

**Expected Results:**
- Average response time: < 100ms
- No failed requests

### Test 23: Database Query Performance

```bash
# Access database
docker-compose exec database psql -U smartwaste_user -d smartwaste

# Enable query timing
\timing

# Run sample queries
SELECT * FROM "CollectionPoint" LIMIT 10;
SELECT * FROM "User" WHERE email = 'admin@smartwaste.demo';

# Check execution times
# Expected: < 10ms for simple queries
```

### Test 24: Resource Usage Under Load

```bash
# Monitor resources while running
docker stats

# In another terminal, generate load
ab -n 1000 -c 50 http://localhost:3000/api/health

# Observe CPU and memory usage
# Expected: Should stay within limits (< 1GB memory, < 2 CPUs)
```

---

## Final Validation Checklist

Before considering the implementation complete:

### Functionality
- [ ] Docker image builds successfully
- [ ] Docker Compose starts all services
- [ ] Database migrations run automatically
- [ ] Seed data populates correctly
- [ ] Health check endpoint responds
- [ ] Frontend loads in browser
- [ ] Authentication works with demo accounts
- [ ] API endpoints respond correctly

### Persistence
- [ ] Data persists after container restart
- [ ] Docker volume contains PostgreSQL data
- [ ] No data loss on `docker-compose down` (without `-v`)

### Security
- [ ] No secrets in git repository
- [ ] Containers run as non-root user
- [ ] Environment variables used for configuration
- [ ] SQL injection prevention works
- [ ] Network isolation configured

### Documentation
- [ ] README has complete setup instructions
- [ ] Architecture diagrams are clear
- [ ] Deployment guide is comprehensive
- [ ] Demo credentials are documented and work

### CI/CD
- [ ] GitHub Actions workflow is valid
- [ ] Pipeline stages execute successfully
- [ ] Docker image pushed to registry (on main)

### Performance
- [ ] Startup time is acceptable (< 60s)
- [ ] Response times are good (< 100ms)
- [ ] Resource usage within limits

---

## Troubleshooting Common Issues

### Issue: Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000
# Kill process
kill -9 <PID>
```

### Issue: Docker Out of Space

```bash
# Clean up Docker
docker system prune -a --volumes
# Warning: This removes all unused containers, images, volumes!
```

### Issue: Database Connection Failed

```bash
# Check database logs
docker-compose logs database

# Restart database
docker-compose restart database

# Check connection
docker-compose exec database pg_isready -U smartwaste_user
```

### Issue: Build Fails

```bash
# Clear npm cache
rm -rf node_modules package-lock.json
npm cache clean --force

# Rebuild
docker-compose build --no-cache
```

### Issue: Permission Denied

```bash
# Fix script permissions
chmod +x scripts/*.sh

# Fix Docker socket (Linux)
sudo chmod 666 /var/run/docker.sock
```

---

## Test Report Template

After completing all tests, document results:

```
SmartWaste Cloud-Native Testing Report
Date: YYYY-MM-DD
Tester: [Name]

Environment:
- OS: [Ubuntu/macOS/Windows]
- Docker Version: [version]
- Docker Compose Version: [version]

Test Results:
- Docker Build: [PASS/FAIL]
- Docker Compose: [PASS/FAIL]
- Data Persistence: [PASS/FAIL]
- Application Functionality: [PASS/FAIL]
- CI/CD Pipeline: [PASS/FAIL]
- Security: [PASS/FAIL]
- Performance: [PASS/FAIL]

Issues Found:
1. [Issue description]
2. [Issue description]

Recommendations:
1. [Recommendation]
2. [Recommendation]

Overall Status: [READY FOR PRODUCTION / NEEDS WORK]
```

---

## Continuous Testing

For ongoing development, run these regularly:

```bash
# Quick validation (5 minutes)
npm run lint
npx prisma validate
docker-compose ps

# Full validation (15 minutes)
./scripts/setup.sh
# Manual browser testing
# Check logs

# Weekly full test (30 minutes)
# Run all tests in this document
# Update test results
```

---

**Document Version:** 1.0  
**Last Updated:** January 2026  
**Maintained By:** SmartWaste Team
