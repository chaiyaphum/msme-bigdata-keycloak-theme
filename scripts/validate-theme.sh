#!/bin/bash

# MSME Big Data Keycloak Theme Validation Script
# This script validates the theme structure and configuration for Keycloak 26.4.5

# set -e  # Disabled to allow script to continue on errors

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Theme root directory (parent of scripts/)
THEME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}MSME Keycloak Theme Validator${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo "Theme directory: $THEME_ROOT"
echo ""

# Function to print success
success() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS++))
}

# Function to print error
error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
    ((CHECKS++))
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
    ((CHECKS++))
}

# Function to print info
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "=== Checking Theme Structure ==="
echo ""

# Check META-INF
if [ -f "$THEME_ROOT/META-INF/keycloak-themes.json" ]; then
    success "META-INF/keycloak-themes.json exists"

    # Validate JSON syntax
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool "$THEME_ROOT/META-INF/keycloak-themes.json" > /dev/null 2>&1; then
            success "keycloak-themes.json is valid JSON"
        else
            error "keycloak-themes.json is invalid JSON"
        fi
    fi
else
    error "META-INF/keycloak-themes.json missing"
fi

# Check each theme type
THEME_TYPES=("login" "account" "admin" "email" "welcome")

for theme in "${THEME_TYPES[@]}"; do
    echo ""
    echo "--- Checking $theme theme ---"

    if [ -d "$THEME_ROOT/$theme" ]; then
        success "$theme directory exists"

        # Check theme.properties
        if [ -f "$THEME_ROOT/$theme/theme.properties" ]; then
            success "$theme/theme.properties exists"

            # Check for parent=base
            if grep -q "^parent=base" "$THEME_ROOT/$theme/theme.properties"; then
                success "$theme uses parent=base (recommended)"
            else
                warning "$theme does not use parent=base"
            fi

            # Check for version comment
            if grep -q "26.4.5" "$THEME_ROOT/$theme/theme.properties"; then
                success "$theme has version compatibility marker"
            else
                warning "$theme missing version compatibility marker"
            fi
        else
            error "$theme/theme.properties missing"
        fi

        # Check resources directory (except email which may not have one)
        if [ "$theme" != "email" ]; then
            if [ -d "$THEME_ROOT/$theme/resources" ]; then
                success "$theme/resources directory exists"
            else
                warning "$theme/resources directory missing"
            fi
        fi
    else
        error "$theme directory missing"
    fi
done

# Check common resources
echo ""
echo "--- Checking common resources ---"

if [ -d "$THEME_ROOT/common/resources" ]; then
    success "common/resources directory exists"

    # Check for node_modules
    if [ -d "$THEME_ROOT/common/resources/node_modules" ]; then
        success "common/resources/node_modules exists"

        # Check for PatternFly
        if [ -d "$THEME_ROOT/common/resources/node_modules/patternfly" ]; then
            success "PatternFly is present"
        else
            warning "PatternFly not found in node_modules"
        fi
    else
        warning "common/resources/node_modules missing"
    fi

    # Check for web_modules (React)
    if [ -d "$THEME_ROOT/common/resources/web_modules" ]; then
        success "common/resources/web_modules exists"
    else
        warning "common/resources/web_modules missing (needed for modern login)"
    fi
else
    error "common/resources directory missing"
fi

# Check login theme specifics
echo ""
echo "--- Checking login theme details ---"

if [ -f "$THEME_ROOT/login/resources/css/login.css" ]; then
    success "login.css exists"

    # Check file size
    size=$(stat -f%z "$THEME_ROOT/login/resources/css/login.css" 2>/dev/null || stat -c%s "$THEME_ROOT/login/resources/css/login.css" 2>/dev/null)
    if [ "$size" -gt 0 ]; then
        success "login.css is not empty (${size} bytes)"
    else
        error "login.css is empty"
    fi
else
    error "login.css missing"
fi

if [ -f "$THEME_ROOT/login/resources/js/login.js" ]; then
    success "login.js exists"
else
    warning "login.js missing (optional)"
fi

# Check for message bundles
if [ -d "$THEME_ROOT/login/messages" ]; then
    msg_count=$(find "$THEME_ROOT/login/messages" -name "messages_*.properties" | wc -l)
    if [ "$msg_count" -gt 0 ]; then
        success "Found $msg_count language message files"
    else
        warning "No message files found in login/messages"
    fi
fi

# Check images
if [ -d "$THEME_ROOT/login/resources/img" ]; then
    img_count=$(find "$THEME_ROOT/login/resources/img" -type f | wc -l)
    success "Found $img_count image files"

    # Check for large images
    large_images=$(find "$THEME_ROOT/login/resources/img" -type f -size +1M)
    if [ -n "$large_images" ]; then
        warning "Found large images (>1MB):"
        echo "$large_images" | while read img; do
            size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)
            size_mb=$(echo "scale=2; $size/1024/1024" | bc)
            echo "  - $(basename $img): ${size_mb}MB"
        done
        warning "Consider optimizing large images for better performance"
    else
        success "All images are reasonably sized (<1MB)"
    fi
fi

# Check welcome theme specifics
echo ""
echo "--- Checking welcome theme details ---"

if [ -f "$THEME_ROOT/welcome/index.ftl" ]; then
    success "welcome/index.ftl template exists"

    # Check for common template issues
    if grep -q "productNameFull" "$THEME_ROOT/welcome/index.ftl"; then
        success "Template uses \${productNameFull} variable"
    else
        warning "Template might not use proper Keycloak variables"
    fi
else
    error "welcome/index.ftl missing"
fi

# Check documentation files
echo ""
echo "--- Checking documentation ---"

[ -f "$THEME_ROOT/README.md" ] && success "README.md exists" || warning "README.md missing"
[ -f "$THEME_ROOT/CHANGELOG.md" ] && success "CHANGELOG.md exists" || warning "CHANGELOG.md missing"
[ -f "$THEME_ROOT/TESTING.md" ] && success "TESTING.md exists" || warning "TESTING.md missing"

# Check for common issues
echo ""
echo "=== Checking for Common Issues ==="
echo ""

# Check for .gitkeep files that might cause issues
gitkeep_count=$(find "$THEME_ROOT" -name ".gitkeep" 2>/dev/null | wc -l)
if [ "$gitkeep_count" -gt 0 ]; then
    warning "Found $gitkeep_count .gitkeep files (safe but unnecessary)"
else
    success "No .gitkeep files found"
fi

# Check for common path issues in theme.properties files
for theme in "${THEME_TYPES[@]}"; do
    if [ -f "$THEME_ROOT/$theme/theme.properties" ]; then
        # Check for absolute paths (which are wrong)
        if grep -q "^styles=/" "$THEME_ROOT/$theme/theme.properties" || \
           grep -q "^scripts=/" "$THEME_ROOT/$theme/theme.properties"; then
            error "$theme/theme.properties contains absolute paths"
        fi
    fi
done

# Check for backup files
backup_count=$(find "$THEME_ROOT" -name "*.bak" -o -name "*~" | wc -l)
if [ "$backup_count" -gt 0 ]; then
    warning "Found $backup_count backup files (.bak, ~)"
else
    success "No backup files found"
fi

# Summary
echo ""
echo "=== Validation Summary ==="
echo ""
echo -e "Total checks: ${BLUE}$CHECKS${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✓ Theme validation passed! No issues found.${NC}"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Theme validation passed with warnings.${NC}"
    echo -e "Review warnings above for potential improvements."
    exit 0
else
    echo -e "${RED}✗ Theme validation failed!${NC}"
    echo -e "Fix errors above before deploying to production."
    exit 1
fi
