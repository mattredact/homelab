#!/bin/bash
# Run this before pushing to verify no secrets leaked

cd "$(dirname "$0")/.."

echo "Checking for leaked secrets..."

errors=0

# Check for IP addresses (10.x.x.x pattern)
if grep -rE '10\.[0-9]+\.[0-9]+\.[0-9]+' \
    --include="*.yml" --include="*.yaml" --include="*.json" --include="*.md" \
    --exclude-dir=".git" . 2>/dev/null | grep -v "10\.0\.0\.0/8"; then
    echo "FAIL: Found hardcoded IP addresses"
    errors=1
fi

# Check for real hostnames/domains
if grep -rE 'nox\.sh|matt\.my|kobebi|rpi4|lxc-pihole' \
    --include="*.yml" --include="*.yaml" --include="*.json" --include="*.md" \
    --exclude-dir=".git" . 2>/dev/null; then
    echo "FAIL: Found real hostnames/domains"
    errors=1
fi

# Check for email addresses (excluding example.com)
if grep -rE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
    --include="*.yml" --include="*.yaml" --include="*.json" \
    --exclude-dir=".git" . 2>/dev/null | grep -v "example\.com"; then
    echo "FAIL: Found email addresses"
    errors=1
fi

# Check that .env is not tracked
if [[ -f .env ]] && git ls-files --error-unmatch .env 2>/dev/null; then
    echo "FAIL: .env is tracked by git!"
    errors=1
fi

if [[ $errors -eq 0 ]]; then
    echo "OK: No secrets found"
    exit 0
else
    echo ""
    echo "Fix the above issues before pushing"
    exit 1
fi
