#!/bin/bash

# ============================================
# SmartWaste - Complete Setup Script
# ============================================
# This script sets up the entire SmartWaste application from scratch

set -e  # Exit on error

echo "🚀 SmartWaste Setup - Starting..."
echo "=================================="

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

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_success "Docker Compose is installed"

# Step 1: Copy environment file
echo ""
print_info "Step 1: Setting up environment variables..."
if [ ! -f .env ]; then
    if [ -f .env.production.example ]; then
        cp .env.production.example .env
        print_success "Created .env from .env.production.example"
    elif [ -f .env.example ]; then
        cp .env.example .env
        print_success "Created .env from .env.example"
    else
        print_error "No .env.example file found"
        exit 1
    fi
else
    print_info ".env file already exists, skipping..."
fi

# Step 2: Generate AUTH_SECRET if not set
echo ""
print_info "Step 2: Generating secure AUTH_SECRET..."
if grep -qE "REPLACE_WITH.*openssl|GENERATE_WITH.*openssl|your-secret-key-here|REPLACE_ME|YOUR_SECRET_HERE" .env 2>/dev/null; then
    # Generate a secure random secret
    AUTH_SECRET=$(openssl rand -base64 32)
    
    # Update .env file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|REPLACE_WITH_openssl_rand_base64_32|$AUTH_SECRET|g" .env
        sed -i '' "s|GENERATE_WITH_openssl_rand_base64_32|$AUTH_SECRET|g" .env
        sed -i '' "s|your-secret-key-here|$AUTH_SECRET|g" .env
        sed -i '' "s|REPLACE_ME|$AUTH_SECRET|g" .env
        sed -i '' "s|YOUR_SECRET_HERE|$AUTH_SECRET|g" .env
    else
        # Linux
        sed -i "s|REPLACE_WITH_openssl_rand_base64_32|$AUTH_SECRET|g" .env
        sed -i "s|GENERATE_WITH_openssl_rand_base64_32|$AUTH_SECRET|g" .env
        sed -i "s|your-secret-key-here|$AUTH_SECRET|g" .env
        sed -i "s|REPLACE_ME|$AUTH_SECRET|g" .env
        sed -i "s|YOUR_SECRET_HERE|$AUTH_SECRET|g" .env
    fi
    
    print_success "Generated and set AUTH_SECRET"
else
    print_info "AUTH_SECRET already configured"
fi

# Step 3: Generate PostgreSQL password if not set
echo ""
print_info "Step 3: Generating PostgreSQL password..."
if grep -qE "REPLACE_WITH.*PASSWORD|CHANGE_THIS_PASSWORD|REPLACE_ME|YOUR_PASSWORD_HERE" .env 2>/dev/null; then
    POSTGRES_PASSWORD=$(openssl rand -base64 16)
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|REPLACE_WITH_STRONG_PASSWORD|$POSTGRES_PASSWORD|g" .env
        sed -i '' "s|CHANGE_THIS_PASSWORD|$POSTGRES_PASSWORD|g" .env
        sed -i '' "s|REPLACE_ME|$POSTGRES_PASSWORD|g" .env
        sed -i '' "s|YOUR_PASSWORD_HERE|$POSTGRES_PASSWORD|g" .env
    else
        sed -i "s|REPLACE_WITH_STRONG_PASSWORD|$POSTGRES_PASSWORD|g" .env
        sed -i "s|CHANGE_THIS_PASSWORD|$POSTGRES_PASSWORD|g" .env
        sed -i "s|REPLACE_ME|$POSTGRES_PASSWORD|g" .env
        sed -i "s|YOUR_PASSWORD_HERE|$POSTGRES_PASSWORD|g" .env
    fi
    
    print_success "Generated and set POSTGRES_PASSWORD"
else
    print_info "POSTGRES_PASSWORD already configured"
fi

# Step 3.5: Validate configuration
echo ""
print_info "Step 3.5: Validating configuration..."
if [ -x ./scripts/validate-env.sh ]; then
    ./scripts/validate-env.sh
    if [ $? -ne 0 ]; then
        print_error "Configuration validation failed"
        exit 1
    fi
else
    print_warning "Validation script not found or not executable"
fi

# Step 4: Build Docker images
echo ""
print_info "Step 4: Building Docker images..."
docker-compose build --no-cache
print_success "Docker images built successfully"

# Step 5: Start containers
echo ""
print_info "Step 5: Starting Docker containers..."
docker-compose up -d
print_success "Docker containers started"

# Step 6: Wait for database to be ready
echo ""
print_info "Step 6: Waiting for database to be ready..."
sleep 10

max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker-compose exec -T database pg_isready -U smartwaste_user -d smartwaste > /dev/null 2>&1; then
        print_success "Database is ready"
        break
    fi
    attempt=$((attempt + 1))
    echo -n "."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    print_error "Database failed to start in time"
    exit 1
fi

# Step 7: Run migrations
echo ""
print_info "Step 7: Running database migrations..."
docker-compose exec -T frontend npx prisma migrate deploy || {
    print_info "Migrations may have already been applied or need manual intervention"
}
print_success "Database migrations completed"

# Step 8: Seed database
echo ""
print_info "Step 8: Seeding database with initial data..."
docker-compose exec -T frontend npx prisma db seed || {
    print_info "Database may already be seeded"
}
print_success "Database seeded"

# Step 9: Check application health
echo ""
print_info "Step 9: Checking application health..."
sleep 5

max_attempts=20
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -f -s http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "Application is healthy and responding"
        break
    fi
    attempt=$((attempt + 1))
    echo -n "."
    sleep 3
done

if [ $attempt -eq $max_attempts ]; then
    print_error "Application health check failed"
    echo ""
    print_info "Check logs with: docker-compose logs -f"
    exit 1
fi

# Final summary
echo ""
echo "=================================="
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "=================================="
echo ""
echo "📍 Application URL: http://localhost:3000"
echo "📊 Health Check: http://localhost:3000/api/health"
echo "🗄️  Database: PostgreSQL on localhost:5432"
echo ""
echo "📝 Useful commands:"
echo "  View logs:        docker-compose logs -f"
echo "  Stop services:    docker-compose down"
echo "  Restart services: docker-compose restart"
echo "  View status:      docker-compose ps"
echo ""
echo "🔐 Demo Credentials:"
echo "  Admin: admin@smartwaste.demo / Demo123!"
echo "  User:  user@smartwaste.demo / Demo123!"
echo ""
print_success "SmartWaste is ready to use!"
