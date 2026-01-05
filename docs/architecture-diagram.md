# SmartWaste - Architecture Diagram

## System Architecture Overview

This document describes the cloud-native architecture of the SmartWaste application, showing how different components interact to provide a scalable and reliable waste management system.

## High-Level Architecture

```mermaid
graph TB
    User[👤 Utente/Citizen] -->|HTTPS| LB[Load Balancer / CDN]
    Operator[👔 Operatore] -->|HTTPS| LB
    Admin[⚙️ Admin] -->|HTTPS| LB
    
    LB --> Frontend[Frontend Next.js<br/>React Components<br/>Docker Container]
    
    Frontend -->|API Routes| Backend[Backend API Layer<br/>Next.js Server Actions<br/>RESTful Endpoints]
    
    Backend -->|Prisma ORM<br/>Type-Safe Queries| DB[(PostgreSQL Database<br/>Docker Volume<br/>Persistent Storage)]
    
    Backend -->|OAuth 2.0| AuthGoogle[Google OAuth<br/>External Service]
    Backend -->|OAuth 2.0| AuthGitHub[GitHub OAuth<br/>External Service]
    Backend -->|NextAuth.js| AuthLocal[Local Authentication<br/>bcrypt + JWT]
    
    Frontend -->|Leaflet.js| Leaflet[OpenStreetMap API<br/>Map Tiles & Routing]
    Backend -->|Geocoding| Nominatim[Nominatim API<br/>Address Search]
    
    Backend -.->|SMTP| EmailServer[Email Server<br/>Password Reset]
    
    subgraph "Docker Environment"
        Frontend
        Backend
        DB
    end
    
    subgraph "External Services"
        AuthGoogle
        AuthGitHub
        Leaflet
        Nominatim
        EmailServer
    end
    
    style Frontend fill:#0070f3,color:#fff
    style Backend fill:#0070f3,color:#fff
    style DB fill:#336791,color:#fff
    style User fill:#10b981,color:#fff
    style Operator fill:#f59e0b,color:#fff
    style Admin fill:#ef4444,color:#fff
```

## Component Details

### 1. Frontend Layer (Next.js 15 + React 19)

**Technology Stack:**
- **Framework:** Next.js 15 with App Router
- **UI Library:** React 19
- **Styling:** Tailwind CSS 4
- **State Management:** React Hooks
- **Forms:** React Hook Form + Zod validation
- **Maps:** Leaflet.js with OpenStreetMap

**Key Features:**
- Server-Side Rendering (SSR) for SEO
- Progressive Web App (PWA) capabilities
- Responsive design for mobile and desktop
- Client-side routing with instant navigation
- Optimistic UI updates

**Container:**
- Base Image: `node:20-alpine`
- Exposed Port: `3000`
- Health Check: `/api/health`
- Non-root user execution for security

### 2. Backend Layer (Next.js API Routes)

**Technology Stack:**
- **API Framework:** Next.js API Routes (RESTful)
- **ORM:** Prisma 6.5 (Type-safe database access)
- **Authentication:** Auth.js (NextAuth v5)
- **Password Hashing:** bcryptjs
- **Validation:** Zod schemas

**API Endpoints:**
```
POST   /api/auth/signin          - User login
POST   /api/auth/signup          - User registration
GET    /api/collection-points    - List collection points
POST   /api/collection-points    - Create collection point (Operator)
GET    /api/collection-points/:id - Get specific point
PUT    /api/collection-points/:id - Update point (Operator)
DELETE /api/collection-points/:id - Delete point (Admin)
POST   /api/reports              - Create report
GET    /api/reports              - List reports
PUT    /api/reports/:id          - Update report status (Operator)
GET    /api/map                  - Map data for visualization
POST   /api/nominatim            - Geocoding service proxy
GET    /api/health               - Health check endpoint
```

**Authentication Flow:**
```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant AuthJS
    participant Database
    participant OAuth

    User->>Frontend: Login Request
    Frontend->>AuthJS: Authenticate
    
    alt OAuth Login
        AuthJS->>OAuth: Redirect to Provider
        OAuth-->>AuthJS: Authorization Code
        AuthJS->>OAuth: Exchange for Token
        OAuth-->>AuthJS: User Profile
    else Credentials Login
        AuthJS->>Database: Verify Credentials
        Database-->>AuthJS: User Data
    end
    
    AuthJS->>Database: Create/Update Session
    AuthJS-->>Frontend: Set Session Cookie
    Frontend-->>User: Logged In
```

### 3. Database Layer (PostgreSQL 16)

**Schema Overview:**

```
Users (Authentication & Profile)
├── id (UUID)
├── email (unique)
├── password (hashed with bcrypt)
├── role (USER | OPERATOR | ADMIN)
├── name, surname, cellphone
└── OAuth provider info

Operators (Organization Info)
├── userId (FK to Users)
├── organizationName
├── vatNumber
├── telephone
└── website

CollectionPoints (Waste Collection Sites)
├── id
├── operatorId (FK to Operators)
├── name, description
├── wasteTypes (Many-to-Many)
├── schedule (One-to-One)
├── address (One-to-One with coordinates)
├── isActive
├── accessibility, capacity
└── images (JSON)

WasteTypes (Categories of Waste)
├── id
├── name (e.g., "Plastica", "Vetro")
├── description
├── color (for map markers)
├── iconName
└── disposalInfo

Reports (Citizen Reports)
├── id
├── userId (FK to Users)
├── collectionPointId (FK)
├── type (FULL_BIN | DAMAGED | etc.)
├── description
├── status (PENDING | IN_PROGRESS | RESOLVED)
└── images (JSON)
```

**Persistence:**
- Docker Named Volume: `smartwaste_postgres_data`
- Automatic backups recommended for production
- No bind mounts to ensure portability

### 4. External Services Integration

**OpenStreetMap (Leaflet.js):**
- Purpose: Interactive maps and tile rendering
- Integration: Client-side JavaScript library
- Cost: Free and open-source

**Nominatim API:**
- Purpose: Geocoding and reverse geocoding
- Integration: Server-side API proxy
- Rate Limiting: Implemented to respect usage policy

**OAuth Providers:**
- Google OAuth 2.0: Social login
- GitHub OAuth 2.0: Developer-friendly login
- Configuration: Environment variables

## Data Flow Examples

### Creating a Collection Point (Operator)

```mermaid
sequenceDiagram
    participant O as Operator
    participant F as Frontend
    participant API as API Route
    participant Prisma as Prisma ORM
    participant DB as PostgreSQL
    participant Nom as Nominatim

    O->>F: Submit Collection Point Form
    F->>F: Validate with Zod
    F->>API: POST /api/collection-points
    API->>API: Check Authentication
    API->>API: Check Role = OPERATOR
    API->>Nom: Geocode Address
    Nom-->>API: Coordinates
    API->>Prisma: Create CollectionPoint
    Prisma->>DB: INSERT query
    DB-->>Prisma: New record
    Prisma-->>API: Collection Point
    API-->>F: Success Response
    F-->>O: Show Success Message
    F->>F: Refresh Map
```

### Reporting an Issue (Citizen)

```mermaid
sequenceDiagram
    participant C as Citizen
    participant F as Frontend
    participant API as API Route
    participant DB as PostgreSQL
    participant Op as Operator

    C->>F: Report Full Bin
    F->>F: Capture Location
    F->>F: Upload Images (optional)
    F->>API: POST /api/reports
    API->>DB: Create Report
    DB-->>API: Report Created
    API-->>F: Success
    F-->>C: Thank You Message
    
    Note over DB,Op: Operator views dashboard
    Op->>API: GET /api/reports
    API->>DB: Query Reports
    DB-->>API: Reports List
    API-->>Op: Display Reports
    Op->>API: PUT /api/reports/:id (Mark as IN_PROGRESS)
```

## Security Architecture

### Multi-Layer Security

```mermaid
graph TD
    A[Client Request] --> B{HTTPS Layer}
    B --> C[Next.js Security Headers]
    C --> D{Authentication Middleware}
    D -->|Authenticated| E{Authorization Check}
    D -->|Not Authenticated| F[Return 401]
    E -->|Authorized| G[API Handler]
    E -->|Not Authorized| H[Return 403]
    G --> I{Prisma ORM}
    I --> J[Parameterized Queries]
    J --> K[PostgreSQL]
    
    style B fill:#10b981
    style C fill:#10b981
    style D fill:#f59e0b
    style E fill:#f59e0b
    style I fill:#0070f3
    style J fill:#10b981
```

**Security Measures:**

1. **Transport Security:**
   - HTTPS only in production
   - Secure cookies (httpOnly, secure, sameSite)
   - HSTS headers

2. **Authentication:**
   - bcrypt password hashing (10 rounds)
   - JWT session tokens
   - OAuth 2.0 for social login
   - Session expiration and renewal

3. **Authorization:**
   - Role-Based Access Control (RBAC)
   - Middleware for route protection
   - Resource ownership validation

4. **Data Security:**
   - SQL injection prevention (Prisma parameterized queries)
   - XSS protection (React auto-escaping)
   - CSRF protection (Auth.js built-in)
   - Input validation (Zod schemas)

5. **Container Security:**
   - Non-root user execution
   - Minimal Alpine Linux base
   - No secrets in images
   - Regular security updates

## Scalability & Performance

### Horizontal Scaling Strategy

```mermaid
graph LR
    LB[Load Balancer<br/>nginx/HAProxy] --> F1[Frontend<br/>Container 1]
    LB --> F2[Frontend<br/>Container 2]
    LB --> F3[Frontend<br/>Container 3]
    
    F1 --> DB[(PostgreSQL<br/>Primary)]
    F2 --> DB
    F3 --> DB
    
    DB --> R1[(Read Replica 1)]
    DB --> R2[(Read Replica 2)]
    
    style LB fill:#10b981
    style DB fill:#336791,color:#fff
```

**Performance Optimizations:**

1. **Frontend:**
   - Static generation where possible
   - Image optimization (AVIF, WebP)
   - Code splitting and lazy loading
   - CDN for static assets

2. **Backend:**
   - Database query optimization
   - Caching strategies (Redis future)
   - Connection pooling (Prisma)

3. **Database:**
   - Indexed columns for frequent queries
   - Read replicas for scaling reads
   - Regular VACUUM and ANALYZE

## Monitoring & Observability

**Health Checks:**
- Application: `GET /api/health`
- Database: PostgreSQL `pg_isready`
- Container: Docker healthcheck

**Logging:**
- Application logs to stdout/stderr
- Docker logs aggregation
- Structured logging format (JSON)

**Metrics (Future):**
- Response times
- Error rates
- Database query performance
- Resource utilization

## 12-Factor App Compliance

| Factor | Implementation |
|--------|----------------|
| **I. Codebase** | Single Git repository, multiple deployments |
| **II. Dependencies** | Explicitly declared in `package.json`, isolated in containers |
| **III. Config** | Environment variables (`.env` files) |
| **IV. Backing Services** | Database as attached resource via `DATABASE_URL` |
| **V. Build, Release, Run** | Separate stages in Docker multi-stage build |
| **VI. Processes** | Stateless app, sessions in database |
| **VII. Port Binding** | Self-contained, exports HTTP via port 3000 |
| **VIII. Concurrency** | Horizontal scaling via container replication |
| **IX. Disposability** | Fast startup (<40s), graceful shutdown |
| **X. Dev/Prod Parity** | Docker ensures identical environments |
| **XI. Logs** | Stdout/stderr, aggregated by Docker |
| **XII. Admin Processes** | Scripts in `/scripts`, run as one-off containers |

## Technology Decisions & Rationale

### Why Next.js?
- **Full-stack framework:** Combines frontend and backend in one codebase
- **SEO-friendly:** Server-Side Rendering for search engines
- **Performance:** Automatic code splitting, image optimization
- **Developer Experience:** Hot reload, TypeScript support
- **Production-ready:** Used by Vercel, Netflix, TikTok

### Why PostgreSQL over SQLite?
- **Scalability:** Handles concurrent writes better
- **ACID compliance:** Stronger data integrity guarantees
- **Advanced features:** Full-text search, JSON support, replication
- **Cloud-native:** Available as managed service (AWS RDS, Azure Database, etc.)
- **Production standard:** Industry-proven for web applications

### Why Docker?
- **Consistency:** "Works on my machine" → "Works everywhere"
- **Isolation:** Dependencies don't conflict with host system
- **Portability:** Deploy anywhere (AWS, Azure, Railway, local)
- **Scalability:** Easy to replicate and orchestrate
- **CI/CD:** Simplified build and deployment pipeline

### Why Prisma ORM?
- **Type Safety:** Generated TypeScript types from schema
- **Developer Experience:** Intuitive API, great autocomplete
- **Database Agnostic:** Easy to switch databases if needed
- **Migrations:** Built-in migration system
- **Performance:** Efficient query generation

## Deployment Environments

### Local Development
- SQLite for quick setup (optional)
- Docker Compose for full stack
- Hot reload for rapid development

### Staging/Testing
- Docker Compose with PostgreSQL
- Separate database from production
- CI/CD automatic deployment

### Production
- Container orchestration (Kubernetes, ECS, etc.)
- Managed PostgreSQL (RDS, Azure Database)
- CDN for static assets
- Load balancer for high availability
- Monitoring and alerting
- Automated backups

## Future Enhancements

**Short Term:**
- Redis for session storage and caching
- Elasticsearch for advanced search
- Automated database backups
- Prometheus metrics

**Long Term:**
- Microservices architecture (if needed)
- Real-time notifications (WebSockets)
- Mobile native apps (React Native / Capacitor)
- Machine learning for waste categorization
- API rate limiting and throttling

---

**Document Version:** 1.0  
**Last Updated:** January 2026  
**Maintained By:** SmartWaste Team
