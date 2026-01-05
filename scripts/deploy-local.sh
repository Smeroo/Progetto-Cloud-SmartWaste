#!/bin/bash

# ============================================
# SmartWaste - Local Deployment Script
# ============================================
# Quick deployment script for local testing

set -e  # Exit on error

echo "🚀 SmartWaste Local Deployment"
echo "=============================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if .env exists
if [ ! -f .env ]; then
    print_info ".env file not found. Running setup.sh first..."
    ./scripts/setup.sh
    exit 0
fi

# Pull latest changes (if in git repo)
if [ -d .git ]; then
    print_info "Pulling latest changes..."
    git pull origin main || print_info "Could not pull latest changes (not on main branch or no remote)"
fi

# Rebuild containers
print_info "Rebuilding Docker images..."
docker-compose build

# Stop existing containers
print_info "Stopping existing containers..."
docker-compose down

# Start containers
print_info "Starting containers..."
docker-compose up -d

# Wait for services to be healthy
print_info "Waiting for services to be healthy..."
sleep 15

# Check health
if curl -f -s http://localhost:3000/api/health > /dev/null 2>&1; then
    print_success "Application is healthy and running"
else
    print_info "Application may still be starting. Check logs with: docker-compose logs -f"
fi

# Show status
echo ""
echo "=============================="
print_success "Deployment Complete!"
echo "=============================="
echo ""
echo "📍 Application: http://localhost:3000"
echo "📊 Health Check: http://localhost:3000/api/health"
echo ""
echo "📝 Useful commands:"
echo "  View logs:    docker-compose logs -f"
echo "  Stop:         docker-compose down"
echo "  Restart:      docker-compose restart"
echo "  Status:       docker-compose ps"
echo ""
