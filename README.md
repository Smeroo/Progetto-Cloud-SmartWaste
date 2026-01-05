# SmartWaste - Gestione Intelligente dei Rifiuti 🌱♻️

<div align="center">
  <img src="https://img.shields.io/badge/Next.js-15.2-black?style=for-the-badge&logo=next.js" alt="Next.js"/>
  <img src="https://img.shields.io/badge/TypeScript-5.8-blue?style=for-the-badge&logo=typescript" alt="TypeScript"/>
  <img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker" alt="Docker"/>
  <img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Prisma-6.5-2D3748?style=for-the-badge&logo=prisma" alt="Prisma"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
</div>

## 📱 Cos'è SmartWaste?

SmartWaste è un'applicazione web cloud-native che aiuta i cittadini a localizzare i punti di raccolta differenziata più vicini e fornisce informazioni dettagliate su come smaltire correttamente ogni tipo di rifiuto. L'applicazione è completamente containerizzata e pronta per il deployment su qualsiasi cloud provider.

## 🌟 Caratteristiche Principali

### Per Cittadini 👥
- 🔍 **Ricerca Intelligente**: "Dove butto le batterie?" - trova subito il punto più vicino
- 🗺️ **Mappa Interattiva**: Visualizza tutti i punti di raccolta con codifica colori
- ♻️ **Guide allo Smaltimento**: Istruzioni dettagliate per ogni tipo di rifiuto
- 📅 **Orari di Raccolta**: Consulta quando sono aperti i centri di raccolta
- 🚨 **Segnalazioni**: Cassonetti pieni? Danni? Segnala in un tap
- 📍 **Geolocalizzazione**: Trova automaticamente i punti più vicini a te

### Per Operatori/Comuni 🏛️
- ➕ **Gestione Punti**: Aggiungi e modifica i punti di raccolta
- 📊 **Dashboard Segnalazioni**: Monitora e gestisci le segnalazioni dei cittadini
- ✏️ **Aggiornamenti Real-time**: Modifica orari e disponibilità
- 📈 **Statistiche**: Analizza l'utilizzo del servizio

---

## 🏗️ Architettura Cloud-Native

### Stack Tecnologico

#### Frontend
- **Next.js 15** - Framework React con App Router e Server Components
- **TypeScript** - Type safety per codice più robusto
- **Tailwind CSS** - Styling moderno e responsive
- **Leaflet** - Mappe interattive OpenStreetMap
- **React Hook Form + Zod** - Gestione form e validazione

#### Backend
- **Next.js API Routes** - RESTful API endpoints
- **Prisma ORM** - Type-safe database queries
- **PostgreSQL 16** - Database relazionale (produzione)
- **Auth.js (NextAuth)** - Autenticazione completa
  - OAuth (Google, GitHub)
  - Credenziali con bcrypt

#### Infrastructure
- **Docker** - Containerizzazione applicazione
- **Docker Compose** - Orchestrazione multi-container
- **GitHub Actions** - CI/CD pipeline
- **PostgreSQL Docker Volume** - Persistenza dati

### Principi 12-Factor App

SmartWaste segue i [12-Factor App principles](https://12factor.net/) per applicazioni cloud-native:

| Factor | Implementazione |
|--------|----------------|
| **I. Codebase** | Repository Git unico, multiple deployments |
| **II. Dependencies** | `package.json` esplicito, isolamento Docker |
| **III. Config** | Environment variables (`.env`) |
| **IV. Backing Services** | PostgreSQL come servizio esterno |
| **V. Build, Release, Run** | Fasi separate nel Dockerfile multi-stage |
| **VI. Processes** | Stateless, sessioni su database |
| **VII. Port Binding** | Self-contained, espone porta 3000 |
| **VIII. Concurrency** | Scale orizzontale via container |
| **IX. Disposability** | Fast startup (<40s), graceful shutdown |
| **X. Dev/Prod Parity** | Docker garantisce parità ambienti |
| **XI. Logs** | Stdout/stderr, aggregati da Docker |
| **XII. Admin Processes** | Script in `/scripts` |

### Scelte Architetturali

**Perché Next.js?**
- Full-stack framework (frontend + backend unified)
- Server-Side Rendering per SEO ottimale
- API Routes per backend senza server separato
- Ottimizzazioni automatiche (code splitting, image optimization)
- Ecosystem React maturo e supportato

**Perché PostgreSQL invece di SQLite?**
- Scalabilità: migliori performance con carico concorrente
- ACID compliance: garanzie di integrità dati più forti
- Features avanzate: full-text search, JSON support, replication
- Cloud-ready: disponibile come managed service su tutti i provider
- Production-proven: standard industriale per web apps

**Perché Docker?**
- Consistency: "Funziona sul mio computer" → "Funziona ovunque"
- Isolation: zero conflitti con host system
- Portability: deploy identico su AWS, Azure, Railway, locale
- Scalability: replicazione facile e orchestrazione
- CI/CD: build e deployment semplificati

---

## 🚀 Quick Start - Build da Zero

> **⚠️ IMPORTANTE - CONFIGURAZIONE OBBLIGATORIA**  
> **Il file `.env` con secrets sicuri è OBBLIGATORIO per avviare l'applicazione.**  
> I valori di fallback sono stati rimossi per motivi di sicurezza. Se non configuri correttamente le variabili d'ambiente, il deployment fallirà immediatamente.
> 
> **Non saltare la configurazione!** Segui il setup automatico o manuale per generare secrets sicuri.

### Prerequisiti

- **Docker** >= 24.0 ([Installa Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** >= 2.20 ([Installa Compose](https://docs.docker.com/compose/install/))
- **Git** ([Installa Git](https://git-scm.com/downloads))
- **8GB RAM** (raccomandato)
- **10GB spazio disco** libero

### Setup Automatico (Raccomandato)

> **📌 Nota Importante:** Lo script `setup.sh` genera automaticamente secrets sicuri per te. È il modo più semplice e sicuro per iniziare.

```bash
# 1. Clone repository
git clone https://github.com/Smeroo/Progetto-Cloud-SmartWaste.git
cd Progetto-Cloud-SmartWaste

# 2. Setup completo automatico (genera secrets, build, start, migrate, seed)
./scripts/setup.sh

# 3. Apri browser
open http://localhost:3000
```

Lo script `setup.sh` esegue automaticamente:
- ✅ Copia `.env.production.example` → `.env`
- ✅ Genera `AUTH_SECRET` sicuro con OpenSSL (32 bytes)
- ✅ Genera password PostgreSQL sicura (16 bytes)
- ✅ Build immagini Docker
- ✅ Avvio containers (PostgreSQL + Next.js)
- ✅ Run database migrations
- ✅ Seed database con dati demo
- ✅ Health check applicazione
- ✅ Validazione completa della configurazione

### Setup Manuale

> **⚠️ ATTENZIONE:** Il setup manuale richiede che tu generi manualmente secrets sicuri. **NON usare valori deboli o placeholder!**

Se preferisci controllare ogni step:

```bash
# 1. Clone repository
git clone https://github.com/Smeroo/Progetto-Cloud-SmartWaste.git
cd Progetto-Cloud-SmartWaste

# 2. Copia file di configurazione
cp .env.production.example .env

# 3. Genera AUTH_SECRET sicuro (OBBLIGATORIO!)
openssl rand -base64 32
# Copia l'output e sostituiscilo in .env alla voce AUTH_SECRET

# 4. Genera POSTGRES_PASSWORD sicura (OBBLIGATORIA!)
openssl rand -base64 16
# Copia l'output e sostituiscilo in .env alla voce POSTGRES_PASSWORD

# 5. Valida la configurazione (IMPORTANTE!)
./scripts/validate-env.sh
# Questo script verifica che tutti i secrets siano configurati correttamente

# 6. (Opzionale) Configura OAuth providers
# Edita .env e aggiungi AUTH_GOOGLE_ID, AUTH_GOOGLE_SECRET, etc.

# 7. Build Docker images
docker-compose build

# 8. Avvia containers
docker-compose up -d

# 9. Attendi che il database sia pronto
docker-compose logs -f database
# Premi CTRL+C quando vedi "database system is ready to accept connections"

# 10. Run migrations
docker-compose exec frontend npx prisma migrate deploy

# 11. Seed database
docker-compose exec frontend npx prisma db seed

# 12. Verifica che tutto funzioni
curl http://localhost:3000/api/health
# Output atteso: {"status":"healthy","database":"connected"}

# 13. Apri browser
open http://localhost:3000
```

### ⚠️ Problemi Comuni durante il Setup

**Errore: "POSTGRES_PASSWORD is required"**
- **Causa:** Il file `.env` non contiene una password valida per PostgreSQL
- **Soluzione:** 
  ```bash
  openssl rand -base64 16
  # Copia il risultato e aggiornalo in .env come POSTGRES_PASSWORD
  ```

**Errore: "AUTH_SECRET is required"**
- **Causa:** Il file `.env` non contiene un secret valido per Auth.js
- **Soluzione:**
  ```bash
  openssl rand -base64 32
  # Copia il risultato e aggiornalo in .env come AUTH_SECRET
  ```

**Lo script validate-env.sh fallisce**
- **Causa:** Secrets deboli o placeholder ancora presenti
- **Soluzione:** Usa sempre `openssl rand -base64` per generare secrets forti
- **NON usare mai:** password generiche, "change_me", "secret-key", ecc.

### 🔒 Generazione Secrets Sicuri

Per garantire la sicurezza del tuo deployment, genera sempre secrets forti:

```bash
# Auth Secret (minimo 32 caratteri)
openssl rand -base64 32

# Database Password (minimo 16 caratteri)  
openssl rand -base64 16

# Password generiche per altri servizi
openssl rand -hex 20
```

**❌ NON usare mai:**
- Password semplici tipo "password123"
- Valori placeholder tipo "change_me" o "your-secret-here"
- Secrets copiati da esempi online
- Stessa password per più servizi

**✅ SEMPRE:**
- Genera secrets unici per ogni deployment
- Usa almeno 32 caratteri per AUTH_SECRET
- Usa almeno 16 caratteri per POSTGRES_PASSWORD
- Valida con `./scripts/validate-env.sh` prima di avviare

---

## 🐳 Comandi Docker Utili

```bash
# Visualizza stato containers
docker-compose ps

# Visualizza logs in real-time
docker-compose logs -f

# Visualizza logs solo del frontend
docker-compose logs -f frontend

# Visualizza logs solo del database
docker-compose logs -f database

# Riavvia servizi
docker-compose restart

# Ferma servizi (mantiene dati)
docker-compose down

# Ferma e rimuovi TUTTO (inclusi volumi dati - ATTENZIONE!)
docker-compose down -v

# Rebuild dopo modifiche al codice
docker-compose build --no-cache
docker-compose up -d

# Accedi alla shell del container
docker-compose exec frontend sh

# Accedi al database PostgreSQL
docker-compose exec database psql -U smartwaste_user -d smartwaste

# Esegui Prisma Studio (GUI database)
docker-compose exec frontend npx prisma studio
# Apri http://localhost:5555
```

---

## 🧪 Testing

### Test Manuali

```bash
# 1. Test health endpoint
curl http://localhost:3000/api/health

# 2. Test API collection points
curl http://localhost:3000/api/collection-points

# 3. Test autenticazione
# Vai su http://localhost:3000 e prova login
```

### Test Automatici

```bash
# Lint del codice
npm run lint

# Type checking TypeScript
npx tsc --noEmit

# Validazione schema Prisma
npx prisma validate

# Test con Docker
docker-compose exec frontend npm run lint
docker-compose exec frontend npx tsc --noEmit
```

### Test Persistenza Dati

Verifica che i dati persistano anche dopo restart:

```bash
# 1. Accedi a SmartWaste e crea alcuni dati (registrazione, collection points, etc.)

# 2. Ferma containers
docker-compose down

# 3. Riavvia containers
docker-compose up -d

# 4. Verifica che i dati siano ancora presenti
# I dati sono salvati nel Docker Volume `smartwaste_postgres_data`
```

---

## 🌐 Deployment in Produzione

### Opzioni di Deployment

#### 1. **Railway** (Più Facile - Raccomandato per Studenti)

**Vantaggi:**
- ✅ Setup in 5 minuti
- ✅ Free tier ($5 credit/mese)
- ✅ Auto-deploy da GitHub
- ✅ HTTPS automatico
- ✅ PostgreSQL integrato

**Costi:** Free tier o ~$10-20/mese

**Steps:**
1. Vai su [railway.app](https://railway.app) e connetti GitHub
2. Seleziona questo repository
3. Aggiungi PostgreSQL plugin
4. Configura environment variables:
   ```
   DATABASE_URL=(auto-configurato da Railway)
   AUTH_SECRET=(genera con: openssl rand -base64 32)
   AUTH_URL=https://your-app.railway.app
   NODE_ENV=production
   ```
5. Deploy automatico! 🎉

#### 2. **AWS (Scalabile - Per Produzione)**

**Servizi utilizzati:**
- ECS Fargate (container orchestration)
- RDS PostgreSQL (managed database)
- Application Load Balancer
- CloudFront CDN

**Costi stimati:** ~$105/mese

**Setup:**
```bash
# 1. Install AWS CLI
brew install awscli  # macOS
# or: apt-get install awscli  # Linux

# 2. Configure credentials
aws configure

# 3. Create RDS database
aws rds create-db-instance \
  --db-instance-identifier smartwaste-prod \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username smartwaste \
  --master-user-password <STRONG_PASSWORD>

# 4. Create ECS cluster
aws ecs create-cluster --cluster-name smartwaste-cluster

# 5. Deploy with GitHub Actions
# Pipeline automaticamente farà push su ECR e update ECS
```

#### 3. **Azure (Economico)**

**Servizi utilizzati:**
- App Service (container hosting)
- Azure Database for PostgreSQL

**Costi stimati:** ~$43/mese

**Setup:**
```bash
# 1. Install Azure CLI
brew install azure-cli  # macOS

# 2. Login
az login

# 3. Create resource group
az group create --name smartwaste-rg --location eastus

# 4. Create PostgreSQL
az postgres flexible-server create \
  --resource-group smartwaste-rg \
  --name smartwaste-db \
  --admin-user smartwaste \
  --admin-password <STRONG_PASSWORD>

# 5. Deploy container
az webapp create \
  --resource-group smartwaste-rg \
  --plan smartwaste-plan \
  --name smartwaste-app \
  --deployment-container-image-name ghcr.io/smeroo/progetto-cloud-smartwaste:latest
```

### Variabili d'Ambiente per Produzione

> **⚠️ SICUREZZA CRITICA:** Tutte le variabili obbligatorie devono essere configurate con valori forti. Il deployment fallirà se mancano o contengono placeholder.

**OBBLIGATORIE (il deployment fallisce se mancanti):**
```env
DATABASE_URL="postgresql://user:password@host:5432/smartwaste"
AUTH_SECRET="<openssl rand -base64 32>"          # MINIMO 32 caratteri
POSTGRES_PASSWORD="<openssl rand -base64 16>"   # MINIMO 16 caratteri
AUTH_URL="https://your-domain.com"
NODE_ENV="production"
```

**RACCOMANDATE:**
```env
NEXT_TELEMETRY_DISABLED=1
```

**OPZIONALI:**
```env
# OAuth Providers
AUTH_GOOGLE_ID="your-google-client-id"
AUTH_GOOGLE_SECRET="your-google-client-secret"
AUTH_GITHUB_ID="your-github-client-id"
AUTH_GITHUB_SECRET="your-github-client-secret"

# Email (password reset)
EMAIL_SERVER="smtp://user:pass@smtp.gmail.com:587"
EMAIL_FROM="noreply@smartwaste.app"
```

---

## 🔐 Credenziali Demo

> **⚠️ SOLO PER AMBIENTE DI SVILUPPO/DEMO**  
> Questi account sono creati automaticamente dallo script di seed per facilitare il testing.  
> **IN PRODUZIONE**: Cambia tutte le password o rimuovi questi account prima del deployment pubblico!

Per testare l'applicazione, usa questi account pre-configurati:

### Account Admin
```
Email: admin@smartwaste.demo
Password: Demo123!
Ruolo: Amministratore (gestione completa sistema)
```

### Account Operatore
```
Email: operator@smartwaste.demo
Password: Demo123!
Ruolo: Operatore (gestione punti raccolta)
```

### Account Utente
```
Email: user@smartwaste.demo
Password: Demo123!
Ruolo: Cittadino (visualizzazione e segnalazioni)
```

**⚠️ Nota di Sicurezza:**  
Questi account sono creati automaticamente dal seed script (`prisma/seed.ts`) con password hard-coded.  
Sono pensati **SOLO** per ambiente di sviluppo locale e demo.  

**Prima del deployment in produzione:**
- Modifica le password di questi account
- Oppure rimuovi completamente gli account demo dal seed script
- Crea account amministratore con password forte tramite interfaccia di registrazione

---

## 📊 CI/CD Pipeline

Il progetto include una pipeline CI/CD completa con GitHub Actions.

### Pipeline Stages

```mermaid
graph LR
    A[Push to GitHub] --> B[Build & Test]
    B --> C[Lint & Type Check]
    C --> D[Security Scan]
    D --> E[Build Docker Image]
    E --> F[Push to GHCR]
    F --> G[Deploy]
```

### Workflow Triggers

- ✅ Push su branch `main` o `develop`
- ✅ Pull request verso `main`
- ✅ Manual workflow dispatch

### Jobs Eseguiti

1. **Build**: Compila Next.js e genera artifacts
2. **Test**: ESLint, TypeScript check, Prisma validate
3. **Security**: npm audit, secret detection
4. **Docker**: Build immagine e push su GitHub Container Registry
5. **Deploy**: (opzionale) Deploy automatico su Railway/AWS/Azure

### Visualizza Pipeline

```bash
# Lista workflow runs
gh run list

# Visualizza logs specifici
gh run view <run-id> --log

# Re-run workflow fallito
gh run rerun <run-id>
```

---

## 📁 Struttura del Progetto

```
SmartWaste/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── docs/
│   ├── architecture-diagram.md    # Diagrammi architettura sistema
│   └── deployment-diagram.md      # Diagrammi deployment strategy
├── prisma/
│   ├── schema.prisma              # Database schema (PostgreSQL)
│   ├── migrations/                # Database migrations
│   └── seed.ts                    # Seed data script
├── public/                        # Static assets
├── scripts/
│   ├── setup.sh                   # Setup automatico completo
│   └── deploy-local.sh            # Deploy locale veloce
├── src/
│   ├── app/                       # Next.js App Router
│   │   ├── api/                   # API routes
│   │   │   ├── health/            # Health check endpoint
│   │   │   ├── auth/              # Authentication endpoints
│   │   │   ├── collection-points/ # Collection points CRUD
│   │   │   └── reports/           # Reports endpoints
│   │   ├── (auth)/                # Auth pages (login, register)
│   │   ├── dashboard/             # User dashboards
│   │   └── map/                   # Map view
│   ├── components/                # React components
│   ├── lib/                       # Utility functions
│   ├── services/                  # Business logic
│   ├── types/                     # TypeScript types
│   ├── auth.ts                    # Auth.js configuration
│   └── middleware.ts              # Next.js middleware
├── .dockerignore                  # Docker build exclusions
├── .env.example                   # Dev environment template
├── .env.production.example        # Production environment template
├── .gitignore                     # Git exclusions
├── docker-compose.yml             # Multi-container orchestration
├── Dockerfile                     # Multi-stage build definition
├── next.config.ts                 # Next.js configuration
├── package.json                   # Dependencies & scripts
├── tsconfig.json                  # TypeScript configuration
└── README.md                      # This file
```

---

## 🔧 Configurazione Avanzata

### OAuth Setup (Google)

1. Vai su [Google Cloud Console](https://console.cloud.google.com/)
2. Crea nuovo progetto "SmartWaste"
3. Abilita "Google+ API"
4. Crea credenziali OAuth 2.0
5. Aggiungi redirect URI: `http://localhost:3000/api/auth/callback/google`
6. Copia Client ID e Client Secret in `.env`:
   ```env
   AUTH_GOOGLE_ID="your-client-id.apps.googleusercontent.com"
   AUTH_GOOGLE_SECRET="your-client-secret"
   ```

### OAuth Setup (GitHub)

1. Vai su [GitHub Developer Settings](https://github.com/settings/developers)
2. New OAuth App
3. Application name: "SmartWaste"
4. Homepage URL: `http://localhost:3000`
5. Callback URL: `http://localhost:3000/api/auth/callback/github`
6. Copia Client ID e Client Secret in `.env`:
   ```env
   AUTH_GITHUB_ID="your-client-id"
   AUTH_GITHUB_SECRET="your-client-secret"
   ```

### Email Setup (Gmail SMTP)

```env
EMAIL_SERVER="smtp://your-email@gmail.com:your-app-password@smtp.gmail.com:587"
EMAIL_FROM="noreply@smartwaste.app"
```

**Nota:** Devi creare una "App Password" in Google Account settings.

---

## 🛠️ Sviluppo Locale (Senza Docker)

Se preferisci sviluppare senza Docker:

```bash
# 1. Install dependencies
npm install

# 2. Setup SQLite per dev locale
cp .env.example .env
# Modifica DATABASE_URL="file:./dev.db"

# 3. Generate Prisma client
npx prisma generate

# 4. Run migrations
npx prisma migrate dev

# 5. Seed database
npx prisma db seed

# 6. Start dev server
npm run dev

# 7. Open browser
open http://localhost:3000
```

---

## 📚 API Endpoints

Documentazione completa in [API_ENDPOINTS.md](./API_ENDPOINTS.md).

### Principali Endpoints

```
Authentication:
  POST   /api/auth/signin              - Login
  POST   /api/auth/signup              - Registration
  POST   /api/auth/signout             - Logout

Collection Points:
  GET    /api/collection-points        - List all
  POST   /api/collection-points        - Create (Operator only)
  GET    /api/collection-points/:id    - Get specific
  PUT    /api/collection-points/:id    - Update (Operator only)
  DELETE /api/collection-points/:id    - Delete (Admin only)

Reports:
  GET    /api/reports                  - List reports
  POST   /api/reports                  - Create report
  PUT    /api/reports/:id              - Update status (Operator)

Map:
  GET    /api/map                      - Get map data

Health:
  GET    /api/health                   - Health check
```

---

## 🔒 Sicurezza

### Best Practices Implementate

✅ **Transport Security:**
- HTTPS obbligatorio in produzione
- Secure cookies (httpOnly, secure, sameSite)
- HSTS headers

✅ **Authentication:**
- Password hashing con bcrypt (10 rounds)
- JWT session tokens
- OAuth 2.0 social login
- Session expiration automatica

✅ **Authorization:**
- Role-Based Access Control (USER, OPERATOR, ADMIN)
- Middleware per protezione routes
- Validazione ownership risorse

✅ **Data Security:**
- SQL injection prevention (Prisma ORM)
- XSS protection (React auto-escaping)
- CSRF protection (Auth.js built-in)
- Input validation (Zod schemas)

✅ **Container Security:**
- Non-root user execution
- Minimal Alpine Linux base image
- No secrets in Docker images
- Regular security updates

### Vulnerability Scanning

```bash
# NPM audit
npm audit

# Docker image scan (Trivy)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image smartwaste-app:latest

# Security in CI/CD
# Automaticamente eseguito in GitHub Actions pipeline
```

---

## 🐛 Troubleshooting

### Database connection failed

```bash
# Check if database is running
docker-compose ps

# Check database logs
docker-compose logs database

# Restart database
docker-compose restart database

# Check database connection
docker-compose exec database psql -U smartwaste_user -d smartwaste
```

### Build fails

```bash
# Clear Docker cache and rebuild
docker-compose build --no-cache

# Check Docker disk space
docker system df

# Prune unused Docker resources
docker system prune -a
```

### Port already in use

```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "3001:3000"  # Use 3001 instead
```

### Auth not working

```bash
# Regenerate AUTH_SECRET
openssl rand -base64 32

# Update .env file with new secret

# Restart containers
docker-compose restart
```

---

## 🤝 Contributing

Contributi benvenuti! Per favore:

1. Fork del repository
2. Crea feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Apri Pull Request

---

## 📄 License

Questo progetto è rilasciato sotto licenza MIT. Vedi [LICENSE](LICENSE) per dettagli.

---

## 👥 Team

Sviluppato per il corso di Cloud Computing.

---

## 📞 Supporto

Per problemi o domande:
- 🐛 [Apri un Issue](https://github.com/Smeroo/Progetto-Cloud-SmartWaste/issues)
- 📧 Email: support@smartwaste.app
- 📚 [Documentazione](./docs/)

---

## 🎓 Risorse Utili

- [Next.js Documentation](https://nextjs.org/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [12-Factor App](https://12factor.net/)
- [Auth.js Documentation](https://authjs.dev/)

---

<div align="center">
  <p>Realizzato con ❤️ per un futuro più sostenibile 🌱</p>
  <p>SmartWaste © 2026</p>
</div>
