#!/usr/bin/env bash
set -euo pipefail

bash prepare-assets.sh

rm -rf dist
mkdir -p dist
cp index.html styles.css reset.css app.js data.js dist/
cp -R assets dist/assets

echo "Prepared Vercel output: 25 papers, 148 questions, and 156 marking images (including multi-part explanations)."
