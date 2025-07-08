#!/bin/bash

# Manual error mode
set -o nounset -o pipefail

# =========[ Auto Dependency Installer ]=========
install_dependencies() {
  echo "🔧 Installing dependencies: optipng, ffmpeg, zip"

  if command -v apt >/dev/null 2>&1; then
    sudo apt update -qq
    sudo apt install -y -qq optipng ffmpeg zip
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y optipng ffmpeg zip
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm optipng ffmpeg zip
  else
    echo "❌ Unsupported package manager. Please install optipng, ffmpeg, and zip manually."
    exit 1
  fi
}

# =========[ Dependency Check ]=========
for cmd in optipng ffmpeg zip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    install_dependencies
    break
  fi
done
echo "✅ Dependencies are installed."

# =========[ Ask for Directory ]=========
read -rp "📁 Enter the full path to your resource pack folder: " SRC_DIR
if [[ ! -d "$SRC_DIR" ]]; then
  echo "❌ Directory does not exist: $SRC_DIR"
  exit 1
fi

# =========[ Prepare Workspace ]=========
WORK_DIR="optimize_work"
UNPACK_DIR="$WORK_DIR/unpacked"
OUTPUT_ZIP="optimized-pack.zip"

rm -rf "$WORK_DIR" "$OUTPUT_ZIP"
mkdir -p "$UNPACK_DIR"
cp -r "$SRC_DIR"/. "$UNPACK_DIR"/

# =========[ PNG Optimization ]=========
echo "=============================="
echo "🖼️  Optimizing PNG files..."
echo "=============================="

mapfile -t PNGS < <(find "$UNPACK_DIR" -type f -iname '*.png')
total_png=${#PNGS[@]}
echo "📦 Found $total_png PNG file(s)."

i=0
for file in "${PNGS[@]}"; do
  ((i++))
  echo "🛠️  [$i/$total_png] $file"
  if ! optipng -o7 -fix "$file" > /dev/null 2>&1; then
    echo "⚠️  Failed to optimize: $file"
  fi
done
echo "✅ PNG optimization complete."

# =========[ OGG Compression ]=========
echo "=============================="
echo "🔊 Compressing OGG files..."
echo "=============================="

mapfile -t OGGS < <(find "$UNPACK_DIR" -type f -iname '*.ogg')
total_ogg=${#OGGS[@]}
echo "📦 Found $total_ogg OGG file(s)."

if [[ "$total_ogg" -eq 0 ]]; then
  echo "⚠️  No OGG files found!"
else
  i=0
  for file in "${OGGS[@]}"; do
    ((i++))
    echo "🔄 [$i/$total_ogg] $file"
    ffmpeg -v error -y -i "$file" -c:a libvorbis -qscale:a 3 "${file}.tmp.ogg" > /dev/null 2>&1
    if [[ -f "${file}.tmp.ogg" ]]; then
      mv -f "${file}.tmp.ogg" "$file"
    else
      echo "⚠️  Failed to compress: $file"
    fi
  done
  echo "✅ OGG compression complete."
fi

# =========[ Create ZIP ]=========
echo "=============================="
echo "📦 Creating $OUTPUT_ZIP"
echo "=============================="

(cd "$UNPACK_DIR" && zip -rq "../../$OUTPUT_ZIP" .) || {
  echo "❌ Failed to zip optimized pack."
  exit 1
}

# =========[ Cleanup ]=========
rm -rf "$WORK_DIR"

echo "✅ All done! Output: $(realpath "$OUTPUT_ZIP")"
