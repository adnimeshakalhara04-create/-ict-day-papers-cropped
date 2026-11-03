#!/usr/bin/env bash
set -euo pipefail

bash prepare-assets.sh

rm -rf dist
mkdir -p dist
cp index.html styles.css reset.css app.js data.js dist/
cp -R assets dist/assets

echo "Prepared Vercel output: 27 papers, 164 questions, and 177 marking images (including multi-part explanations)."
