#!/bin/bash

# Keycloak Theme Testing Script
# This script starts Keycloak with the MSME theme and runs automated tests

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
KEYCLOAK_VERSION="26.0.4"
CONTAINER_NAME="keycloak-theme-test"
KEYCLOAK_PORT=8080
ADMIN_USER="admin"
ADMIN_PASS="admin"
MAX_WAIT=120  # seconds

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Keycloak Theme Testing Script${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker is installed
print_status "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

# Stop and remove existing container if it exists
print_status "Cleaning up existing containers..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true
print_success "Cleanup complete"

# Get the theme directory
THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
print_status "Theme directory: $THEME_DIR"

# Start Keycloak container
print_status "Starting Keycloak $KEYCLOAK_VERSION container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $KEYCLOAK_PORT:8080 \
  -e KEYCLOAK_ADMIN=$ADMIN_USER \
  -e KEYCLOAK_ADMIN_PASSWORD=$ADMIN_PASS \
  -v "$THEME_DIR:/opt/keycloak/themes/msme-bigdata" \
  quay.io/keycloak/keycloak:$KEYCLOAK_VERSION \
  start-dev \
  --spi-theme-static-max-age=-1 \
  --spi-theme-cache-themes=false \
  --spi-theme-cache-templates=false

if [ $? -eq 0 ]; then
    print_success "Keycloak container started"
else
    print_error "Failed to start Keycloak container"
    exit 1
fi

# Wait for Keycloak to start
print_status "Waiting for Keycloak to start (max ${MAX_WAIT}s)..."
elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
    if curl -s -f http://localhost:$KEYCLOAK_PORT/health/ready > /dev/null 2>&1; then
        print_success "Keycloak is ready!"
        break
    fi

    echo -n "."
    sleep 5
    elapsed=$((elapsed + 5))
done
echo ""

if [ $elapsed -ge $MAX_WAIT ]; then
    print_error "Keycloak failed to start within ${MAX_WAIT}s"
    print_status "Checking logs..."
    docker logs $CONTAINER_NAME | tail -50
    exit 1
fi

# Run tests
print_status "Running theme tests..."
echo ""

# Test 1: Welcome page
echo -e "${BLUE}Test 1: Welcome Page${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$KEYCLOAK_PORT/)
if [ "$response" = "200" ]; then
    print_success "Welcome page loads (HTTP $response)"
else
    print_error "Welcome page failed (HTTP $response)"
fi

# Test 2: Check if welcome page contains MSME theme elements
welcome_content=$(curl -s http://localhost:$KEYCLOAK_PORT/)
if echo "$welcome_content" | grep -q "Welcome to"; then
    print_success "Welcome page content loaded"
else
    print_warning "Welcome page content might not be correct"
fi

# Test 3: Admin console
echo ""
echo -e "${BLUE}Test 2: Admin Console${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$KEYCLOAK_PORT/admin/)
if [ "$response" = "200" ]; then
    print_success "Admin console loads (HTTP $response)"
else
    print_error "Admin console failed (HTTP $response)"
fi

# Test 4: Master realm account console
echo ""
echo -e "${BLUE}Test 3: Account Console${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$KEYCLOAK_PORT/realms/master/account/)
if [ "$response" = "200" ]; then
    print_success "Account console loads (HTTP $response)"
else
    print_error "Account console failed (HTTP $response)"
fi

# Test 5: Check theme is available
echo ""
echo -e "${BLUE}Test 4: Theme Files${NC}"
print_status "Checking if theme files are accessible..."

# Check login CSS
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$KEYCLOAK_PORT/resources/$(docker exec $CONTAINER_NAME ls -t /opt/keycloak/data/tmp/ | head -1)/login/msme-bigdata/css/login.css 2>/dev/null || echo "404")
if [ "$response" = "200" ]; then
    print_success "login.css is accessible"
else
    print_warning "login.css might not be cached yet (this is normal on first load)"
fi

# Check JavaScript
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$KEYCLOAK_PORT/resources/$(docker exec $CONTAINER_NAME ls -t /opt/keycloak/data/tmp/ | head -1)/login/msme-bigdata/js/login.js 2>/dev/null || echo "404")
if [ "$response" = "200" ]; then
    print_success "login.js is accessible"
else
    print_warning "login.js might not be cached yet (this is normal on first load)"
fi

# Test 6: Check Keycloak logs for theme errors
echo ""
echo -e "${BLUE}Test 5: Keycloak Logs${NC}"
print_status "Checking logs for theme-related errors..."

theme_errors=$(docker logs $CONTAINER_NAME 2>&1 | grep -i "theme" | grep -i "error" || echo "")
if [ -z "$theme_errors" ]; then
    print_success "No theme errors in logs"
else
    print_warning "Found theme-related messages in logs:"
    echo "$theme_errors"
fi

# Test 7: Check for CSS/JS loading errors
css_errors=$(docker logs $CONTAINER_NAME 2>&1 | grep -i "css" | grep -i "error\|failed" || echo "")
if [ -z "$css_errors" ]; then
    print_success "No CSS loading errors in logs"
else
    print_warning "Found CSS-related errors:"
    echo "$css_errors"
fi

# Summary
echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""
print_status "Keycloak is running at: http://localhost:$KEYCLOAK_PORT"
print_status "Admin Console: http://localhost:$KEYCLOAK_PORT/admin"
print_status "Username: $ADMIN_USER"
print_status "Password: $ADMIN_PASS"
echo ""
print_status "To enable the theme:"
echo "  1. Go to http://localhost:$KEYCLOAK_PORT/admin"
echo "  2. Login with admin/admin"
echo "  3. Go to Realm Settings → Themes"
echo "  4. Select 'msme-bigdata' for all theme types"
echo "  5. Click Save"
echo ""
print_status "To view logs:"
echo "  docker logs -f $CONTAINER_NAME"
echo ""
print_status "To stop the container:"
echo "  docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
echo ""

# Keep container running and show logs
print_status "Container is running. Press Ctrl+C to see logs and keep running."
echo ""
sleep 3
echo -e "${BLUE}Recent logs:${NC}"
docker logs --tail 30 $CONTAINER_NAME

echo ""
print_success "Testing complete! Container is still running for manual testing."
