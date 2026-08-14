#!/usr/bin/env bash
set -euo pipefail

PART0="assets-pack.part-00"
PART1="assets-pack.part-01"
ZIP="/tmp/ict-day-papers-assets.zip"

if [[ -d assets/questions && -d assets/markings ]]; then
  q_count=$(find assets/questions -type f -name '*.webp' | wc -l | tr -d ' ')
  m_count=$(find assets/markings -type f -name '*.webp' | wc -l | tr -d ' ')
  if [[ "$q_count" == "126" && "$m_count" == "126" ]]; then
    echo "Fresh crop assets already present: 126 questions + 126 markings."
    exit 0
  fi
fi

[[ -f "$PART0" ]] || { echo "Missing $PART0"; exit 1; }
[[ -f "$PART1" ]] || { echo "Missing $PART1"; exit 1; }

echo "34e5df118fbc8f9e595741e8b6be00809a234908eb531c0542a4ddbc6626f1c8  $PART0" | sha256sum -c -
echo "448790cda12367c2538693f47e7d03268ca623c125ea2b55a549eedf228ddc96  $PART1" | sha256sum -c -
cat "$PART0" "$PART1" > "$ZIP"
echo "2e1ff0c06cbb4c72f2c57671b2f6be5cc7d698baade6380ddfd1ff853234f2ca  $ZIP" | sha256sum -c -
unzip -q -o "$ZIP" -d .

q_count=$(find assets/questions -type f -name '*.webp' | wc -l | tr -d ' ')
m_count=$(find assets/markings -type f -name '*.webp' | wc -l | tr -d ' ')
[[ "$q_count" == "126" ]] || { echo "Expected 126 question crops, got $q_count"; exit 1; }
[[ "$m_count" == "126" ]] || { echo "Expected 126 marking crops, got $m_count"; exit 1; }

echo "Verified fresh assets: 126 question crops + 126 marking crops."
