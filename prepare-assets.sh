#!/usr/bin/env bash
set -euo pipefail

PART0="assets-pack.part-00"
PART1="assets-pack.part-01"
ZIP="/tmp/ict-day-papers-assets.zip"
EXPECTED=(0 7 6 7 7 6 5 5 5 6 6 4 6 6 6 7 7 8 8 4 6 4 6 5 5 6)

count_crops() {
  find "$1" -type f \( -name '*.webp' -o -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | wc -l | tr -d ' '
}

verify_assets() {
  [[ -d assets/questions && -d assets/markings ]] || return 1

  local q_total m_total n folder expected q_count m_count i file ext
  q_total=$(count_crops assets/questions)
  m_total=$(count_crops assets/markings)

  [[ "$q_total" == "148" ]] || { echo "Expected 148 question crops, got $q_total"; return 1; }
  [[ "$m_total" == "148" ]] || { echo "Expected 148 marking crops, got $m_total"; return 1; }

  for n in $(seq 1 25); do
    folder=$(printf 'phy-%02d' "$n")
    expected=${EXPECTED[$n]}
    ext='webp'
    [[ "$n" == "22" ]] && ext='jpg'
    [[ "$n" -ge 23 ]] && ext='png'

    [[ -d "assets/questions/$folder" ]] || { echo "Missing assets/questions/$folder"; return 1; }
    [[ -d "assets/markings/$folder" ]] || { echo "Missing assets/markings/$folder"; return 1; }

    q_count=$(find "assets/questions/$folder" -maxdepth 1 -type f -name "q-*.$ext" | wc -l | tr -d ' ')
    m_count=$(find "assets/markings/$folder" -maxdepth 1 -type f -name "q-*.$ext" | wc -l | tr -d ' ')

    [[ "$q_count" == "$expected" ]] || { echo "$folder expected $expected question crops, got $q_count"; return 1; }
    [[ "$m_count" == "$expected" ]] || { echo "$folder expected $expected marking crops, got $m_count"; return 1; }

    for i in $(seq 1 "$expected"); do
      file=$(printf 'q-%02d.%s' "$i" "$ext")
      [[ -s "assets/questions/$folder/$file" ]] || { echo "Missing/empty question asset: $folder/$file"; return 1; }
      [[ -s "assets/markings/$folder/$file" ]] || { echo "Missing/empty marking asset: $folder/$file"; return 1; }
    done
  done

  echo "Verified exact asset map: 25 papers, 148 questions + 148 markings."
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

NEW_ZIP="/tmp/ict-day-papers-phy23-25-crops.zip"
NEW_ZIP_URL="https://drive.usercontent.google.com/download?id=1j6FcHexNbd-a97ehm-IWJ3B0j0n9d8JE&export=download&confirm=t"

echo "Downloading verified PHY 23-25 crop bundle from Google Drive..."
curl -fL --retry 3 --retry-delay 2 "$NEW_ZIP_URL" -o "$NEW_ZIP"
echo "c96e6e891e327258b1b4e15abf6987c8601c6812baf5ca5a859ad618577e7d9f  $NEW_ZIP" | sha256sum -c -
unzip -tq "$NEW_ZIP" >/dev/null
mkdir -p assets
unzip -q -o "$NEW_ZIP" -d assets

verify_assets
