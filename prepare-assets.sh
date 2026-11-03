#!/usr/bin/env bash
set -euo pipefail

PART0="assets-pack.part-00"
PART1="assets-pack.part-01"
ZIP="/tmp/ict-day-papers-assets.zip"
EXPECTED=(0 7 6 7 7 6 5 5 5 6 6 4 6 6 6 7 7 8 8 4 6 4 6 5 5 6 8 8)

count_crops() {
  find "$1" -type f \( -name '*.webp' -o -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | wc -l | tr -d ' '
}

verify_assets() {
  [[ -d assets/questions && -d assets/markings ]] || return 1

  local q_total m_total n folder expected q_count m_count i file ext
  q_total=$(count_crops assets/questions)
  m_total=$(count_crops assets/markings)

  [[ "$q_total" == "164" ]] || { echo "Expected 164 question crops, got $q_total"; return 1; }
  [[ "$m_total" == "177" ]] || { echo "Expected 177 marking crops, got $m_total"; return 1; }

  for n in $(seq 1 27); do
    folder=$(printf 'phy-%02d' "$n")
    expected=${EXPECTED[$n]}
    ext='webp'
    [[ "$n" == "22" ]] && ext='jpg'
    [[ "$n" -ge 23 && "$n" -le 25 ]] && ext='png'

    [[ -d "assets/questions/$folder" ]] || { echo "Missing assets/questions/$folder"; return 1; }
    [[ -d "assets/markings/$folder" ]] || { echo "Missing assets/markings/$folder"; return 1; }

    q_count=$(find "assets/questions/$folder" -maxdepth 1 -type f -name "q-*.$ext" | wc -l | tr -d ' ')
    m_count=$(find "assets/markings/$folder" -maxdepth 1 -type f -name "q-*.$ext" | wc -l | tr -d ' ')
    mark_expected="$expected"
    [[ "$n" == "23" ]] && mark_expected=7
    [[ "$n" == "24" ]] && mark_expected=6
    [[ "$n" == "25" ]] && mark_expected=11
    [[ "$n" == "26" ]] && mark_expected=11
    [[ "$n" == "27" ]] && mark_expected=10

    [[ "$q_count" == "$expected" ]] || { echo "$folder expected $expected question crops, got $q_count"; return 1; }
    [[ "$m_count" == "$mark_expected" ]] || { echo "$folder expected $mark_expected marking crops, got $m_count"; return 1; }

    for i in $(seq 1 "$expected"); do
      file=$(printf 'q-%02d.%s' "$i" "$ext")
      [[ -s "assets/questions/$folder/$file" ]] || { echo "Missing/empty question asset: $folder/$file"; return 1; }

      case "$n-$i" in
        23-4|23-5|24-2|25-2|25-3|25-4|25-5|25-6|26-4|26-5|26-7|27-1|27-3)
          part1=$(printf 'q-%02d-01.%s' "$i" "$ext")
          part2=$(printf 'q-%02d-02.%s' "$i" "$ext")
          [[ -s "assets/markings/$folder/$part1" ]] || { echo "Missing/empty marking asset: $folder/$part1"; return 1; }
          [[ -s "assets/markings/$folder/$part2" ]] || { echo "Missing/empty marking asset: $folder/$part2"; return 1; }
          ;;
        *)
          [[ -s "assets/markings/$folder/$file" ]] || { echo "Missing/empty marking asset: $folder/$file"; return 1; }
          ;;
      esac
    done
  done

  echo "Verified exact asset map: 27 papers, 164 questions + 177 marking images."
  return 0
}

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
echo "15b69006f5808c36c56b447233459a1941091c8d43b2cf3e5323be7ced9d169c  $NEW_ZIP" | sha256sum -c -
unzip -tq "$NEW_ZIP" >/dev/null
mkdir -p assets
unzip -q -o "$NEW_ZIP" -d assets


# Immutable source-verified PHY 26-27 crop pack, uploaded through Drive and
# committed in SHA-verified chunks. Fail the deployment on any mismatch.
EXTRA_PART_DIR="updates/phy26-27"
EXTRA_ZIP="/tmp/ict-day-papers-phy26-27-crops.zip"
echo "Verifying PHY 26-27 original-source crop bundle..."
echo "b531b56affcfaabb6b016ee29007df438d11727c2416b209e9126d7f40ab6c7a  $EXTRA_PART_DIR/part-00" | sha256sum -c -
echo "b2cfcb096a50376e307501055eb2ff394a4c104407ecdf97319609223db25bdf  $EXTRA_PART_DIR/part-01" | sha256sum -c -
echo "08f074041b88ea6ac05a6fea288dd4704e05ff86734f53224569b57494bb6e44  $EXTRA_PART_DIR/part-02" | sha256sum -c -
echo "cfd52f71f804424feb8564fb42f999824ee860409fc2131b9b4e813aed1a05d7  $EXTRA_PART_DIR/part-03" | sha256sum -c -
cat "$EXTRA_PART_DIR"/part-* > "$EXTRA_ZIP"
echo "a1a0499268d2874c58d5290bbc57c283e09cf39c795002b8ae6d07c2e7ced8c9  $EXTRA_ZIP" | sha256sum -c -
unzip -tq "$EXTRA_ZIP" >/dev/null
unzip -q -o "$EXTRA_ZIP" -d .

verify_assets
