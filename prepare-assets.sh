#!/usr/bin/env bash
set -euo pipefail

PART0="assets-pack.part-00"
PART1="assets-pack.part-01"
ZIP="/tmp/ict-day-papers-assets.zip"
EXPECTED=(0 7 6 7 7 6 5 5 5 6 6 4 6 6 6 7 7 8 8 4 6 4)

verify_assets() {
  [[ -d assets/questions && -d assets/markings ]] || return 1

  local q_total m_total n folder expected q_count m_count i file
  q_total=$(find assets/questions -type f -name '*.webp' | wc -l | tr -d ' ')
  m_total=$(find assets/markings -type f -name '*.webp' | wc -l | tr -d ' ')

  [[ "$q_total" == "126" ]] || { echo "Expected 126 question crops, got $q_total"; return 1; }
  [[ "$m_total" == "126" ]] || { echo "Expected 126 marking crops, got $m_total"; return 1; }

  for n in $(seq 1 21); do
    folder=$(printf 'phy-%02d' "$n")
    expected=${EXPECTED[$n]}

    [[ -d "assets/questions/$folder" ]] || { echo "Missing assets/questions/$folder"; return 1; }
    [[ -d "assets/markings/$folder" ]] || { echo "Missing assets/markings/$folder"; return 1; }

    q_count=$(find "assets/questions/$folder" -maxdepth 1 -type f -name 'q-*.webp' | wc -l | tr -d ' ')
    m_count=$(find "assets/markings/$folder" -maxdepth 1 -type f -name 'q-*.webp' | wc -l | tr -d ' ')

    [[ "$q_count" == "$expected" ]] || { echo "$folder expected $expected question crops, got $q_count"; return 1; }
    [[ "$m_count" == "$expected" ]] || { echo "$folder expected $expected marking crops, got $m_count"; return 1; }

    for i in $(seq 1 "$expected"); do
      file=$(printf 'q-%02d.webp' "$i")
      [[ -s "assets/questions/$folder/$file" ]] || { echo "Missing/empty question asset: $folder/$file"; return 1; }
      [[ -s "assets/markings/$folder/$file" ]] || { echo "Missing/empty marking asset: $folder/$file"; return 1; }
    done
  done

  echo "Verified exact asset map: 21 papers, 126 questions + 126 markings."
  return 0
}

if verify_assets; then
  echo "Fresh crop assets already present and fully verified."
  exit 0
fi

[[ -f "$PART0" ]] || { echo "Missing $PART0"; exit 1; }
[[ -f "$PART1" ]] || { echo "Missing $PART1"; exit 1; }

echo "34e5df118fbc8f9e595741e8b6be00809a234908eb531c0542a4ddbc6626f1c8  $PART0" | sha256sum -c -
echo "448790cda12367c2538693f47e7d03268ca623c125ea2b55a549eedf228ddc96  $PART1" | sha256sum -c -
cat "$PART0" "$PART1" > "$ZIP"
echo "2e1ff0c06cbb4c72f2c57671b2f6be5cc7d698baade6380ddfd1ff853234f2ca  $ZIP" | sha256sum -c -
unzip -tq "$ZIP" >/dev/null
unzip -q -o "$ZIP" -d .

verify_assets
