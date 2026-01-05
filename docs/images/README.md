# SmartWaste - Diagram Images

Questa cartella contiene le versioni esportate dei diagrammi Mermaid presenti nei file markdown della documentazione.

## 📊 Diagrammi Disponibili

### Architettura
- `architecture-overview.svg` - Panoramica architettura sistema completo
- `authentication-flow.svg` - Flusso di autenticazione (sequence diagram)
- `security-architecture.svg` - Architettura di sicurezza multi-layer
- `scaling-strategy.svg` - Strategia di scaling orizzontale

### CI/CD Pipeline
- `cicd-pipeline.svg` - Flusso completo della pipeline
- `cicd-build-stage.svg` - Dettaglio stage di build
- `cicd-test-stage.svg` - Dettaglio stage di test
- `cicd-security-stage.svg` - Dettaglio stage di security scan

### Deployment
- `deployment-local.svg` - Deployment ambiente locale
- `deployment-aws.svg` - Deployment su AWS
- `deployment-azure.svg` - Deployment su Azure
- `deployment-railway.svg` - Deployment su Railway

## 🔍 Nota sui File SVG

I file SVG in questa cartella sono **placeholder visivi** che indicano la presenza dei diagrammi Mermaid.

### Perché placeholder?
- I diagrammi completi sono definiti nei file markdown (`.md`) usando sintassi Mermaid
- I file SVG servono come riferimento visivo per professori/revisori che potrebbero non avere strumenti Mermaid
- GitHub e molti visualizzatori markdown renderizzano automaticamente i diagrammi Mermaid

### Visualizzare i Diagrammi Completi

**Opzione 1: GitHub (Raccomandato)**
- Apri i file `.md` direttamente su GitHub
- GitHub renderizza automaticamente i diagrammi Mermaid in modo interattivo

**Opzione 2: VS Code**
- Installa l'estensione "Markdown Preview Mermaid Support"
- Apri i file `.md` con preview

**Opzione 3: Mermaid Live Editor**
- Vai su https://mermaid.live/
- Copia e incolla il codice Mermaid dai file `.md`

**Opzione 4: Generare SVG Reali**
Se desideri generare vere versioni SVG dai diagrammi Mermaid:
```bash
# Installa mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Estrai diagrammi dai file markdown
# (richiede script personalizzato o estrazione manuale)

# Genera SVG
mmdc -i diagram.mmd -o output.svg
```

## 📚 Riferimenti

- **Documentazione Architettura**: `../architecture-diagram.md`
- **Documentazione Deployment**: `../deployment-diagram.md`
- **Mermaid Documentation**: https://mermaid.js.org/

---

**Nota**: I file SVG placeholder sono stati creati automaticamente per garantire che la documentazione sia accessibile anche senza strumenti specializzati.
