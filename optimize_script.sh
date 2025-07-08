#!/bin/bash

set -e

# =========[ Auto Dependency Installer ]=========
install_dependencies() {
  echo "Checking and installing dependencies: optipng, ffmpeg"

  # Detect package manager
  if command -v apt >/dev/null; then
    PKG_INSTALL="sudo apt install -y"
    PKG_UPDATE="sudo apt update"
  elif command -v dnf >/dev/null; then
    PKG_INSTALL="sudo dnf install -y"
    PKG_UPDATE="sudo dnf check-update"
  elif command -v pacman >/dev/null; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
    PKG_UPDATE="sudo pacman -Sy"
  else
    echo "Unsupported package manager. Please install 'optipng' and 'ffmpeg' manually."
    exit 1
  fi

  # Update package list and install
  $PKG_UPDATE
  $PKG_INSTALL optipng ffmpeg
}

# Check if tools are already installed
if ! command -v optipng >/dev/null || ! command -v ffmpeg >/dev/null; then
  install_dependencies
else
  echo "Dependencies already installed."
fi

# =========[ User Input ]=========
read -rp "Enter the full path to your resource pack folder: " target_folder

if [[ ! -d "$target_folder" ]]; then
  echo "Folder does not exist: $target_folder"
  exit 1
fi

# =========[ PNG Optimization ]=========
echo "========================"
echo "Optimizing PNG files..."
echo "========================"

find "$target_folder" -type f -iname '*.png' | while read -r file; do
  echo "Processing: $file"
  optipng -o7 "$file"
done

# =========[ OGG Compression ]=========
echo "========================"
echo "Compressing OGG files..."
echo "========================"

find "$target_folder" -type f -iname '*.ogg' | while read -r file; do
  echo "Processing: $file"
  ffmpeg -y -i "$file" -ac 1 -ab 64k "${file}.tmp.ogg"
  if [[ -f "${file}.tmp.ogg" ]]; then
    mv -f "${file}.tmp.ogg" "$file"
  fi
done

echo "========================"
echo "Optimization complete."
