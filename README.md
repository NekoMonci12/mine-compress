# 🛠️ Mine Compress

A Linux shell script to optimize Minecraft resource packs by reducing the size of `.png` and `.ogg` files without losing significant quality.

---

## ✨ Features

- 🔍 Recursively scans a target folder
- 🖼️ Optimizes `.png` files using `optipng -o7`
- 🔊 Re-encodes `.ogg` files with `ffmpeg` to mono, 64kbps
- 📦 Automatically installs required dependencies (Debian, Fedora, Arch)
- ✅ Interactive CLI input

---

## 🚀 How It Works

1. **User submits an issue** using the issue template.
2. The issue is labeled `optimize-request`.
3. GitHub Actions parses the issue form, downloads the `.zip`, optimizes assets, and re‑uploads the optimized `.zip` as an artifact.

---

## 🧾 Usage

### 1. Clone Repository
```bash
git clone https://github.com/NekoMonci12/mine-compress.git
cd mine-compress
chmod +x optimize_resources.sh
```

### 2. Run The Scripts
```bash
./optimize_resources.sh
```

## 📦 Requirements
- optipng
- ffmpeg
- zip
---

## 📥 Github Workflows

1. [**Click Here**](https://github.com/NekoMonci12/mine-compress/issues/new?template=optimize_request.yml) For Create New Issue.
2. Provide a **public `.zip` URL** of your resource pack.
3. The issue is automatically tagged with `optimize-request`.
4. GitHub Actions runs the optimization workflow.

Once the workflow completes, you’ll find the optimized `.zip` under the **Actions → Artifacts → optimized-pack** section.
