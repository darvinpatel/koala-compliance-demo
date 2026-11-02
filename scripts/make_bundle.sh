#!/usr/bin/env bash
# Build dist/koala-compliance-demo.zip for copying to another machine. No .venv, no secrets, no machine paths.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$PWD"
rm -rf dist && mkdir -p dist/koala-compliance-demo
cp -r README.md DEMO.md PATH-TO-PROD.md SETUP-WORK-LAPTOP.md .github config data mod scripts fallback output dist/koala-compliance-demo/
find dist/koala-compliance-demo \( -name '__pycache__' -o -name '.powerpipe' -o -name '*.pyc' \) -prune -exec rm -rf {} +
# Powerpipe reports record the folder they ran in; replace this machine's path with the bundle name.
sed -i "s#$REPO#koala-compliance-demo#g" dist/koala-compliance-demo/output/reports/*
if grep -rIl -e "$REPO" -e "$HOME" dist/koala-compliance-demo; then echo "machine-specific path found (above)"; exit 1; fi
(cd dist && python3 -m zipfile -c koala-compliance-demo.zip koala-compliance-demo && rm -rf koala-compliance-demo)
ls -l dist/koala-compliance-demo.zip
