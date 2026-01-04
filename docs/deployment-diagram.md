# SmartWaste - Deployment Diagram & Strategy

## Deployment Architecture Overview

This document outlines the deployment strategy for SmartWaste, including CI/CD pipeline, container registry, and cloud provider options.

## CI/CD Pipeline Flow

```mermaid
graph LR
    Dev[👨‍💻 Developer] -->|git push| GitHub[📦 GitHub Repository]
    GitHub -->|webhook| Actions[⚙️ GitHub Actions<br/>CI/CD Pipeline]
    
    Actions --> Build[🔨 Build Stage<br/>- Install deps<br/>- Run tests<br/>- Build Docker image]
    Build --> Test[🧪 Test Stage<br/>- Lint code<br/>- Type check<br/>- Prisma validate]
    Test --> Security[🔒 Security Stage<br/>- Vulnerability scan<br/>- Dependency audit<br/>- SAST analysis]
    Security --> Push[📤 Push Stage<br/>- Tag image<br/>- Push to GHCR]
    Push --> Deploy[🚀 Deploy Stage<br/>- Update production<br/>- Run migrations<br/>- Health check]
    
    Deploy --> Cloud[☁️ Cloud Provider<br/>AWS/Azure/Railway]
    
    style Build fill:#0070f3,color:#fff
    style Test fill:#10b981,color:#fff
    style Security fill:#f59e0b,color:#fff
    style Deploy fill:#ef4444,color:#fff
    style Cloud fill:#8b5cf6,color:#fff
```

## Detailed CI/CD Stages

### 1. Trigger Events

```yaml
Triggers:
  - Push to main branch
  - Pull request to main
  - Manual workflow dispatch
  - Schedule (nightly builds)
```

### 2. Build Stage

```mermaid
graph TD
    A[Checkout Code] --> B[Setup Node.js 20]
    B --> C[Cache Dependencies]
    C --> D[Install Dependencies]
    D --> E[Generate Prisma Client]
    E --> F[Build Next.js App]
    F --> G[Build Docker Image]
    G --> H{Build Success?}
    H -->|Yes| I[Save Build Artifacts]
    H -->|No| J[❌ Fail Pipeline]
    
    style A fill:#0070f3,color:#fff
    style G fill:#0070f3,color:#fff
    style I fill:#10b981,color:#fff
    style J fill:#ef4444,color:#fff
```

**Actions:**
- Checkout repository code
- Setup Node.js environment
- Restore npm cache (faster builds)
- Install dependencies (`npm ci`)
- Generate Prisma client
- Build Next.js application
- Build Docker image with multi-stage Dockerfile
- Tag image with commit SHA and branch name

### 3. Test Stage

```mermaid
graph TD
    A[Run ESLint] --> B{Linting Passed?}
    B -->|Yes| C[TypeScript Type Check]
    B -->|No| Z[❌ Fail]
    C --> D{Type Check Passed?}
    D -->|Yes| E[Prisma Schema Validate]
    D -->|No| Z
    E --> F{Schema Valid?}
    F -->|Yes| G[Unit Tests]
    F -->|No| Z
    G --> H{Tests Passed?}
    H -->|Yes| I[✅ All Tests Pass]
    H -->|No| Z
    
    style I fill:#10b981,color:#fff
    style Z fill:#ef4444,color:#fff
```

**Checks:**
- **Linting:** ESLint with Next.js config
- **Type Checking:** TypeScript compiler (`tsc --noEmit`)
- **Schema Validation:** Prisma schema validation
- **Unit Tests:** Jest/Vitest tests (if configured)
- **Integration Tests:** API endpoint tests

### 4. Security Stage

```mermaid
graph TD
    A[Dependency Audit] --> B{Vulnerabilities?}
    B -->|Critical/High| C[❌ Block Deployment]
    B -->|Low/Medium| D[⚠️ Warning]
    B -->|None| E[Container Scan]
    E --> F{Container Issues?}
    F -->|Yes| G[⚠️ Report Issues]
    F -->|No| H[SAST Analysis]
    H --> I[Security Report]
    
    style C fill:#ef4444,color:#fff
    style D fill:#f59e0b,color:#fff
    style I fill:#10b981,color:#fff
```

**Security Checks:**
- **npm audit:** Check for vulnerable dependencies
- **Trivy/Grype:** Scan Docker image for vulnerabilities
- **CodeQL:** Static Application Security Testing (SAST)
- **Secret Detection:** Ensure no secrets in code
- **License Compliance:** Check dependency licenses

### 5. Push to Registry

```mermaid
graph LR
    A[Docker Image] -->|Login| B[GitHub Container Registry<br/>ghcr.io]
    B -->|Tag| C[Image Tags:<br/>- latest<br/>- commit-SHA<br/>- semantic version]
    C -->|Push| D[Stored Image]
    D --> E[Available for Deployment]
    
    style B fill:#0070f3,color:#fff
    style D fill:#10b981,color:#fff
```

**Image Tags:**
```
ghcr.io/smeroo/smartwaste:latest
ghcr.io/smeroo/smartwaste:v1.0.0
ghcr.io/smeroo/smartwaste:sha-abc123
ghcr.io/smeroo/smartwaste:main
```

### 6. Deploy Stage

```mermaid
sequenceDiagram
    participant CI as GitHub Actions
    participant Registry as Container Registry
    participant Cloud as Cloud Provider
    participant DB as Database
    participant App as Application
    
    CI->>Registry: Pull Latest Image
    CI->>Cloud: Deploy New Version
    Cloud->>Registry: Pull Image
    Registry-->>Cloud: Docker Image
    Cloud->>DB: Run Migrations
    DB-->>Cloud: Migrations Complete
    Cloud->>App: Start New Container
    App->>App: Health Check
    App-->>Cloud: Healthy
    Cloud->>Cloud: Route Traffic to New Version
    Cloud->>App: Stop Old Container
    
    Note over CI,App: Zero-downtime deployment
```

**Deployment Steps:**
1. Authenticate with cloud provider
2. Pull latest Docker image from registry
3. Run database migrations (`prisma migrate deploy`)
4. Start new container instance
5. Wait for health check to pass
6. Route traffic to new version
7. Stop old container (after grace period)
8. Verify deployment success

## Container Registry Strategy

### GitHub Container Registry (GHCR)

**Advantages:**
- ✅ Free for public repositories
- ✅ Integrated with GitHub
- ✅ Automatic cleanup of old images
- ✅ Fine-grained access control
- ✅ Supports multi-arch images

**Configuration:**
```yaml
Registry: ghcr.io
Organization: smeroo
Repository: progetto-cloud-smartwaste
Access: GitHub Token (automatic in Actions)
```

**Image Lifecycle:**
- **Latest builds:** Keep last 10
- **Tagged releases:** Keep indefinitely
- **PR builds:** Delete after merge
- **Stale images:** Auto-delete after 30 days

## Deployment Environments

### 1. Local Development Environment

```mermaid
graph TD
    Dev[Developer Laptop] --> Docker[Docker Desktop]
    Docker --> Compose[docker-compose.yml]
    Compose --> Frontend[Frontend Container]
    Compose --> DB[PostgreSQL Container]
    Compose --> Vol[(Docker Volume)]
    
    Frontend --> DB
    DB --> Vol
    
    style Dev fill:#10b981,color:#fff
    style Docker fill:#0070f3,color:#fff
```

**Setup:**
```bash
# Clone repository
git clone https://github.com/Smeroo/Progetto-Cloud-SmartWaste.git
cd Progetto-Cloud-SmartWaste

# Run setup script
./scripts/setup.sh

# Access application
open http://localhost:3000
```

**Characteristics:**
- Full stack running locally
- PostgreSQL in Docker
- Hot reload for development
- No production secrets needed
- Instant feedback loop

### 2. Staging Environment

```mermaid
graph LR
    GitHub[GitHub] -->|Auto-deploy| Staging[Staging Server<br/>staging.smartwaste.app]
    Staging --> StagingDB[(Staging Database)]
    
    style Staging fill:#f59e0b,color:#fff
```

**Purpose:**
- Test before production
- QA and user acceptance testing
- Performance testing
- Database migration testing

**Configuration:**
- Separate database from production
- Test data, not real user data
- Same infrastructure as production
- Automatic deployment on PR merge

### 3. Production Environment

#### Option A: AWS Deployment

```mermaid
graph TB
    Route53[Route 53<br/>DNS] --> CloudFront[CloudFront<br/>CDN]
    CloudFront --> ALB[Application Load Balancer]
    ALB --> ECS1[ECS Task 1<br/>SmartWaste Container]
    ALB --> ECS2[ECS Task 2<br/>SmartWaste Container]
    ALB --> ECS3[ECS Task 3<br/>SmartWaste Container]
    
    ECS1 --> RDS[(RDS PostgreSQL<br/>Multi-AZ)]
    ECS2 --> RDS
    ECS3 --> RDS
    
    RDS --> S3[S3<br/>Backups]
    
    subgraph "VPC"
        ALB
        ECS1
        ECS2
        ECS3
        RDS
    end
    
    style CloudFront fill:#ff9900,color:#fff
    style RDS fill:#336791,color:#fff
```

**AWS Services:**
- **ECS (Fargate):** Container orchestration
- **RDS PostgreSQL:** Managed database
- **Application Load Balancer:** Traffic distribution
- **CloudFront:** CDN for static assets
- **Route 53:** DNS management
- **S3:** Database backups and static files
- **CloudWatch:** Monitoring and logs
- **Secrets Manager:** Secure secrets storage

**Cost Estimate (Monthly):**
- ECS Fargate (2 tasks): ~$50
- RDS PostgreSQL (db.t3.micro): ~$25
- ALB: ~$20
- Data transfer: ~$10
- **Total: ~$105/month**

**Setup Steps:**
```bash
# 1. Create RDS PostgreSQL instance
aws rds create-db-instance \
  --db-instance-identifier smartwaste-prod \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username smartwaste \
  --master-user-password <secure-password>

# 2. Create ECS cluster
aws ecs create-cluster --cluster-name smartwaste-cluster

# 3. Deploy with GitHub Actions
# (Automated via CI/CD pipeline)
```

#### Option B: Azure Deployment

```mermaid
graph TB
    Traffic[Azure Traffic Manager] --> AppService[Azure App Service<br/>Container]
    AppService --> PostgreSQL[(Azure Database<br/>for PostgreSQL)]
    
    AppService --> CDN[Azure CDN]
    PostgreSQL --> Backup[Azure Backup]
    
    style AppService fill:#0078d4,color:#fff
    style PostgreSQL fill:#336791,color:#fff
```

**Azure Services:**
- **App Service:** Web app hosting with containers
- **Azure Database for PostgreSQL:** Managed database
- **Azure CDN:** Content delivery
- **Azure Monitor:** Logging and monitoring
- **Key Vault:** Secrets management

**Cost Estimate (Monthly):**
- App Service (B1): ~$13
- PostgreSQL (Basic): ~$25
- CDN: ~$5
- **Total: ~$43/month**

**Setup Steps:**
```bash
# 1. Create resource group
az group create --name smartwaste-rg --location eastus

# 2. Create PostgreSQL server
az postgres server create \
  --resource-group smartwaste-rg \
  --name smartwaste-db \
  --sku-name B_Gen5_1

# 3. Deploy container
az webapp create \
  --resource-group smartwaste-rg \
  --plan smartwaste-plan \
  --name smartwaste-app \
  --deployment-container-image-name ghcr.io/smeroo/smartwaste:latest
```

#### Option C: Railway Deployment (Easiest)

```mermaid
graph LR
    GitHub[GitHub] -->|Auto-deploy| Railway[Railway Platform]
    Railway --> App[SmartWaste App]
    Railway --> DB[(PostgreSQL Plugin)]
    
    App --> DB
    
    style Railway fill:#0b0d0e,color:#fff
```

**Railway Features:**
- ✅ One-click deployment from GitHub
- ✅ Automatic HTTPS
- ✅ Built-in PostgreSQL
- ✅ Automatic deployments on push
- ✅ Easy environment variables
- ✅ Free tier available ($5 credit/month)

**Cost:**
- Free tier: $5 credit/month
- Paid: ~$10-20/month for small apps

**Setup Steps:**
```bash
# 1. Connect GitHub repository to Railway
# 2. Add PostgreSQL plugin
# 3. Set environment variables
# 4. Deploy automatically

# Railway.app handles everything automatically!
```

**Why Railway is Recommended for Students:**
- Easiest setup (5 minutes)
- Free tier sufficient for demos
- Automatic HTTPS and domains
- No DevOps knowledge required
- Perfect for academic projects

#### Comparison Table

| Feature | AWS | Azure | Railway |
|---------|-----|-------|---------|
| **Ease of Setup** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Cost (Free Tier)** | 12 months | 12 months | Ongoing |
| **Monthly Cost** | $105 | $43 | $10-20 |
| **Scalability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Learning Curve** | High | Medium | Low |
| **Auto-Deploy** | Setup required | Setup required | Built-in |
| **Best For** | Enterprise | Business | Startups/Students |

## Environment Variables Configuration

### Development (.env)
```env
DATABASE_URL="postgresql://user:pass@localhost:5432/smartwaste"
AUTH_SECRET="dev-secret-not-secure"
AUTH_URL="http://localhost:3000"
NODE_ENV="development"
```

### Production (.env.production)
```env
DATABASE_URL="postgresql://user:pass@prod-db:5432/smartwaste"
AUTH_SECRET="<openssl rand -base64 32>"
AUTH_URL="https://smartwaste.app"
NODE_ENV="production"
NEXT_TELEMETRY_DISABLED=1
```

### Cloud Provider Specific

**AWS:**
```env
AWS_REGION="eu-west-1"
DATABASE_URL="<RDS endpoint>"
```

**Azure:**
```env
AZURE_RESOURCE_GROUP="smartwaste-rg"
DATABASE_URL="<Azure PostgreSQL endpoint>"
```

**Railway:**
```env
# Automatically set by Railway
DATABASE_URL="${DATABASE_URL}"
RAILWAY_STATIC_URL="${RAILWAY_STATIC_URL}"
```

## Rollback Strategy

### Automated Rollback

```mermaid
graph TD
    Deploy[Deploy New Version] --> Health{Health Check<br/>Passed?}
    Health -->|Yes| Success[✅ Deployment Complete]
    Health -->|No| Rollback[Rollback to Previous Version]
    Rollback --> Previous[Start Previous Container]
    Previous --> Stop[Stop Failed Container]
    Stop --> Alert[🚨 Alert Team]
    
    style Success fill:#10b981,color:#fff
    style Rollback fill:#f59e0b,color:#fff
    style Alert fill:#ef4444,color:#fff
```

**Rollback Methods:**

1. **Automatic (Health Check Failure):**
   ```bash
   # Automatic in cloud platforms
   # If health check fails for 3 attempts, rollback automatically
   ```

2. **Manual (GitHub Actions):**
   ```bash
   # Re-run previous successful workflow
   # Or deploy specific commit SHA
   gh workflow run deploy.yml -f version=v1.0.0
   ```

3. **Docker Tag:**
   ```bash
   # Pull and deploy previous image
   docker pull ghcr.io/smeroo/smartwaste:v1.0.0
   docker-compose up -d
   ```

## Monitoring & Alerts

```mermaid
graph LR
    App[Application] -->|Metrics| Prometheus[Prometheus<br/>Metrics]
    App -->|Logs| Logs[Log Aggregator]
    App -->|Traces| Traces[Jaeger/Zipkin]
    
    Prometheus --> Grafana[Grafana Dashboard]
    Logs --> ELK[ELK Stack]
    
    Grafana --> Alert[Alerting]
    ELK --> Alert
    Alert -->|Email/Slack| Team[👥 Team]
    
    style App fill:#0070f3,color:#fff
    style Grafana fill:#f59e0b,color:#fff
    style Alert fill:#ef4444,color:#fff
```

**Key Metrics:**
- Response time (p50, p95, p99)
- Error rate
- Request rate
- Database query time
- Container CPU/Memory usage
- Disk usage

**Alerts:**
- Error rate > 5%
- Response time > 2s
- Health check failures
- Database connection errors
- High memory usage (>80%)

## Backup & Disaster Recovery

### Database Backups

```mermaid
graph LR
    DB[(Production DB)] -->|Automated Daily| Backup1[Daily Backup]
    DB -->|Weekly| Backup2[Weekly Backup]
    DB -->|Monthly| Backup3[Monthly Backup]
    
    Backup1 --> S3[S3/Azure Blob<br/>Storage]
    Backup2 --> S3
    Backup3 --> S3
    
    S3 -->|Restore| NewDB[(New Database)]
    
    style DB fill:#336791,color:#fff
    style S3 fill:#ff9900,color:#fff
```

**Backup Strategy:**
- **Daily:** Keep for 7 days
- **Weekly:** Keep for 4 weeks
- **Monthly:** Keep for 12 months

**Restore Process:**
```bash
# 1. Create new database
# 2. Restore from backup
pg_restore -d smartwaste backup.sql

# 3. Update DATABASE_URL
# 4. Restart application
```

## Security Best Practices

### Secrets Management

```mermaid
graph TD
    Dev[Developer] -->|Never commit| GitHub[GitHub Repository]
    GitHub -->|Pull| Actions[GitHub Actions]
    Actions -->|Read| Secrets[GitHub Secrets]
    Secrets -->|Inject as ENV| Deploy[Deployment]
    
    Deploy --> Cloud[Cloud Provider]
    Cloud -->|Read| KV[Key Vault/<br/>Secrets Manager]
    
    style Secrets fill:#10b981,color:#fff
    style KV fill:#10b981,color:#fff
```

**Security Checklist:**
- ✅ Never commit `.env` files
- ✅ Use GitHub Secrets for CI/CD
- ✅ Use cloud provider secrets management in production
- ✅ Rotate secrets regularly (quarterly)
- ✅ Use strong passwords (>32 characters)
- ✅ Enable 2FA for all accounts
- ✅ Regular security audits (`npm audit`)
- ✅ Keep dependencies updated
- ✅ Enable HTTPS only
- ✅ Use secure cookies

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Security scan passed
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] Secrets rotated (if needed)
- [ ] Backup created

### Deployment
- [ ] Deploy to staging first
- [ ] Run smoke tests on staging
- [ ] Deploy to production
- [ ] Monitor health checks
- [ ] Verify application functionality

### Post-Deployment
- [ ] Check error logs
- [ ] Verify metrics dashboard
- [ ] Test critical user flows
- [ ] Monitor for 30 minutes
- [ ] Document deployment in changelog

## Useful Commands

### GitHub Actions
```bash
# View workflow runs
gh run list

# View specific run logs
gh run view <run-id>

# Re-run failed job
gh run rerun <run-id>

# Cancel running workflow
gh run cancel <run-id>
```

### Docker Registry
```bash
# Login to GHCR
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin

# Pull image
docker pull ghcr.io/smeroo/smartwaste:latest

# Tag and push
docker tag smartwaste ghcr.io/smeroo/smartwaste:v1.0.0
docker push ghcr.io/smeroo/smartwaste:v1.0.0
```

### Cloud Deployment
```bash
# AWS ECS
aws ecs update-service --cluster smartwaste --service smartwaste-service --force-new-deployment

# Azure
az webapp restart --name smartwaste-app --resource-group smartwaste-rg

# Railway
railway up
```

---

**Document Version:** 1.0  
**Last Updated:** January 2026  
**Maintained By:** SmartWaste Team
