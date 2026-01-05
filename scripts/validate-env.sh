#!/bin/bash

# ============================================
# SmartWaste - Environment Validation Script
# ============================================
# Questo script verifica che tutte le variabili d'ambiente obbligatorie
# siano configurate prima di avviare l'applicazione

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

echo "🔍 SmartWaste - Validazione Configurazione"
echo "=========================================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    print_error "File .env non trovato!"
    echo ""
    print_info "Crea il file .env copiando .env.production.example:"
    echo "  cp .env.production.example .env"
    echo ""
    exit 1
fi

print_success "File .env trovato"
echo ""

# Load .env file
# Using set -a to safely export variables
set -a
if [ -f .env ]; then
    # Source the file safely, ignoring comments
    source <(grep -v '^#' .env | grep -v '^\s*$')
fi
set +a

# Track validation status
VALIDATION_FAILED=0

# ========================================
# Variabili OBBLIGATORIE
# ========================================
echo "📋 Controllo variabili OBBLIGATORIE:"
echo ""

# 1. DATABASE_URL
if [ -z "$DATABASE_URL" ]; then
    print_error "DATABASE_URL non configurata"
    VALIDATION_FAILED=1
else
    # Check if it's not a placeholder
    if [[ "$DATABASE_URL" == *"REPLACE"* ]] || [[ "$DATABASE_URL" == *"CHANGE"* ]] || [[ "$DATABASE_URL" == *"YOUR_"* ]]; then
        print_error "DATABASE_URL contiene un valore placeholder - configurala correttamente"
        VALIDATION_FAILED=1
    else
        print_success "DATABASE_URL configurata"
    fi
fi

# 2. AUTH_SECRET
# Weak patterns to check against
WEAK_PATTERNS=("REPLACE" "CHANGE" "YOUR_" "please-generate" "secret-key")

if [ -z "$AUTH_SECRET" ]; then
    print_error "AUTH_SECRET non configurata"
    echo "  Genera con: openssl rand -base64 32"
    VALIDATION_FAILED=1
else
    # Check if it's not a weak/placeholder secret
    IS_WEAK=0
    for pattern in "${WEAK_PATTERNS[@]}"; do
        if [[ "$AUTH_SECRET" == *"$pattern"* ]]; then
            IS_WEAK=1
            break
        fi
    done
    
    if [ $IS_WEAK -eq 1 ] || [ ${#AUTH_SECRET} -lt 32 ]; then
        print_error "AUTH_SECRET è debole o è un placeholder"
        echo "  Genera una chiave sicura con: openssl rand -base64 32"
        VALIDATION_FAILED=1
    else
        print_success "AUTH_SECRET configurata (lunghezza: ${#AUTH_SECRET} caratteri)"
    fi
fi

# 3. POSTGRES_PASSWORD
# Weak password patterns
WEAK_PASSWORD_PATTERNS=("REPLACE" "CHANGE" "YOUR_" "password" "smartwaste")

if [ -z "$POSTGRES_PASSWORD" ]; then
    print_error "POSTGRES_PASSWORD non configurata"
    echo "  Genera con: openssl rand -base64 16"
    VALIDATION_FAILED=1
else
    # Check if it's not a weak/placeholder password
    IS_WEAK=0
    for pattern in "${WEAK_PASSWORD_PATTERNS[@]}"; do
        if [[ "$POSTGRES_PASSWORD" == *"$pattern"* ]]; then
            IS_WEAK=1
            break
        fi
    done
    
    if [ $IS_WEAK -eq 1 ] || [ ${#POSTGRES_PASSWORD} -lt 12 ]; then
        print_error "POSTGRES_PASSWORD è debole o è un placeholder"
        echo "  Genera una password sicura con: openssl rand -base64 16"
        VALIDATION_FAILED=1
    else
        print_success "POSTGRES_PASSWORD configurata (lunghezza: ${#POSTGRES_PASSWORD} caratteri)"
    fi
fi

echo ""

# ========================================
# Variabili RACCOMANDATE
# ========================================
echo "📋 Controllo variabili RACCOMANDATE:"
echo ""

# AUTH_URL
if [ -z "$AUTH_URL" ]; then
    print_warning "AUTH_URL non configurata (sarà usato il default)"
else
    print_success "AUTH_URL configurata: $AUTH_URL"
fi

# NODE_ENV
if [ -z "$NODE_ENV" ]; then
    print_warning "NODE_ENV non configurata (consigliato: production)"
elif [ "$NODE_ENV" != "production" ] && [ "$NODE_ENV" != "development" ]; then
    print_warning "NODE_ENV ha un valore insolito: $NODE_ENV"
else
    print_success "NODE_ENV configurata: $NODE_ENV"
fi

echo ""

# ========================================
# Variabili OPZIONALI
# ========================================
echo "📋 Variabili OPZIONALI (OAuth providers, Email):"
echo ""

OPTIONAL_CONFIGURED=0

if [ ! -z "$AUTH_GOOGLE_ID" ] && [ ! -z "$AUTH_GOOGLE_SECRET" ]; then
    print_success "OAuth Google configurato"
    OPTIONAL_CONFIGURED=$((OPTIONAL_CONFIGURED + 1))
fi

if [ ! -z "$AUTH_GITHUB_ID" ] && [ ! -z "$AUTH_GITHUB_SECRET" ]; then
    print_success "OAuth GitHub configurato"
    OPTIONAL_CONFIGURED=$((OPTIONAL_CONFIGURED + 1))
fi

if [ ! -z "$EMAIL_SERVER" ] && [ ! -z "$EMAIL_FROM" ]; then
    print_success "Email server configurato"
    OPTIONAL_CONFIGURED=$((OPTIONAL_CONFIGURED + 1))
fi

if [ $OPTIONAL_CONFIGURED -eq 0 ]; then
    print_info "Nessun servizio opzionale configurato (puoi aggiungerli in seguito)"
else
    print_success "$OPTIONAL_CONFIGURED servizi opzionali configurati"
fi

echo ""
echo "=========================================="

# ========================================
# Final Result
# ========================================
if [ $VALIDATION_FAILED -eq 1 ]; then
    echo ""
    print_error "VALIDAZIONE FALLITA - Configura le variabili obbligatorie mancanti"
    echo ""
    echo "📚 Riferimenti:"
    echo "  - Documentazione: README.md"
    echo "  - File di esempio: .env.production.example"
    echo "  - Generare secrets: openssl rand -base64 32"
    echo ""
    exit 1
else
    echo ""
    print_success "VALIDAZIONE COMPLETATA - Tutte le variabili obbligatorie sono configurate"
    echo ""
    print_success "Puoi avviare l'applicazione con: docker-compose up -d"
    echo ""
    exit 0
fi
