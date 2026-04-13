# 🖱️ macOS-Mouse-Jiggler

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey?logo=apple)
![Language](https://img.shields.io/badge/language-Bash%20%2B%20Swift-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-blue)

Keeps your Mac awake by nudging the mouse cursor 1px left and right every second. No third-party dependencies — just plain Bash and Swift, which ship with macOS.

---

## ✨ Features

- **Zero dependencies** — uses Swift from Xcode Command Line Tools
- **Non-intrusive** — 1px movement won't disrupt normal use
- **Live feedback** — prints a timestamp each second so you know it's running
- **Clean exit** — gracefully handles `Ctrl+C`

---

## 📋 Requirements

- macOS
- Xcode Command Line Tools

> **Don't have them?** The script will tell you. Or install manually:
> ```bash
> xcode-select --install
> ```

---

## 🚀 Quick Start

```bash
# 1. Clone or download the script, then make it executable
chmod +x mouse_jiggler.sh

# 2. Run it
./mouse_jiggler.sh

# 3. Stop it
# Press Ctrl+C
```

---

## 🖥️ Output

```
🖱️  Mouse Jiggler started. Press Ctrl+C to stop.

⏱️  Jiggling... (3:42:07 PM)
```

---

## ⚠️ Permissions

On first run, macOS may prompt you to grant **Accessibility** access to your terminal app.

**System Settings → Privacy & Security → Accessibility → enable your terminal**

This is required for the script to post synthetic mouse events via CoreGraphics.

---

## 📝 Notes

- Has no meaningful impact on battery beyond keeping the display on
- Safe to run in a background terminal tab while you work

---

## 📄 License

MIT — do whatever you want with it.
