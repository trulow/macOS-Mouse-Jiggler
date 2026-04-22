#!/bin/bash

# Mouse Jiggler - Keeps macOS active by moving the mouse 1px left/right every second
# No dependencies — uses Swift which ships with macOS Xcode Command Line Tools
# Usage: ./mouse_jiggler.sh
# Stop:  Press Q (no Enter needed) or Ctrl+C

# Check for Xcode Command Line Tools (required for swift)
if ! command -v swift &>/dev/null; then
  echo "❌ Swift not found. Install Xcode Command Line Tools by running:"
  echo "   xcode-select --install"
  exit 1
fi

# Main menu
echo "🖱️  Mouse Jiggler"
echo ""
echo "  1) 1 hour"
echo "  2) 3 hours"
echo "  3) 6 hours"
echo "  4) 8 hours"
echo "  5) Always (until Q or Ctrl+C)"
echo "  9) Clean up leftover temp files"
echo ""
read -rp "Enter your choice [1-5, 9]: " choice

# Handle cleanup option
if [[ "$choice" == "9" ]]; then
  files=(/tmp/mouse_jiggler_*.swift)
  if [[ -e "${files[0]}" ]]; then
    rm -f /tmp/mouse_jiggler_*.swift
    echo "✅ Cleaned up ${#files[@]} leftover temp file(s)."
  else
    echo "✅ No leftover temp files found."
  fi
  exit 0
fi

case "$choice" in
  1) DURATION=3600;   LABEL="1 hour" ;;
  2) DURATION=10800;  LABEL="3 hours" ;;
  3) DURATION=21600;  LABEL="6 hours" ;;
  4) DURATION=28800;  LABEL="8 hours" ;;
  5) DURATION=0;      LABEL="until cancelled" ;;
  *)
    echo "❌ Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""
echo "✅ Starting — will run $LABEL. Press Q or Ctrl+C to stop early."
echo ""

# Write Swift source to a temp file so it gets a proper stdin file descriptor
SWIFT_TMP=$(mktemp /tmp/mouse_jiggler_XXXXXX.swift)
trap 'rm -f "$SWIFT_TMP"' EXIT

cat > "$SWIFT_TMP" << 'SWIFTEOF'
import Foundation
import CoreGraphics

let duration = Double(CommandLine.arguments[1]) ?? 0
let startTime = Date()

func quit(_ message: String) {
    // Restore terminal before printing
    var term = termios()
    tcgetattr(STDIN_FILENO, &term)
    term.c_lflag |= tcflag_t(ECHO | ICANON)
    tcsetattr(STDIN_FILENO, TCSANOW, &term)
    print("\n\(message)")
    exit(0)
}

signal(SIGINT)  { _ in quit("🛑 Mouse Jiggler stopped.") }
signal(SIGTERM) { _ in quit("🛑 Mouse Jiggler stopped.") }

// Switch stdin to raw mode so Q registers without Enter
var raw = termios()
tcgetattr(STDIN_FILENO, &raw)
raw.c_lflag &= ~tcflag_t(ECHO | ICANON)
raw.c_cc.16 = 1  // VMIN  = 1 byte at a time
raw.c_cc.17 = 0  // VTIME = no timeout
tcsetattr(STDIN_FILENO, TCSANOW, &raw)

// Background thread: watch for Q keypress
Thread.detachNewThread {
    while true {
        var c: UInt8 = 0
        let n = read(STDIN_FILENO, &c, 1)
        if n > 0 && (c == UInt8(ascii: "q") || c == UInt8(ascii: "Q")) {
            quit("🛑 Mouse Jiggler stopped.")
        }
    }
}

var direction: CGFloat = 1.0

while true {
    Thread.sleep(forTimeInterval: 1.0)

    if duration > 0 && Date().timeIntervalSince(startTime) >= duration {
        quit("✅ Time's up! Mouse Jiggler finished.")
    }

    let loc = CGEvent(source: nil)?.location ?? CGPoint.zero
    let newPos = CGPoint(x: loc.x + direction, y: loc.y)
    let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                        mouseCursorPosition: newPos, mouseButton: .left)
    event?.post(tap: .cghidEventTap)
    direction *= -1.0

    let elapsed = Int(Date().timeIntervalSince(startTime))
    let time = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)

    if duration > 0 {
        let remaining = Int(duration) - elapsed
        let hrs = remaining / 3600
        let mins = (remaining % 3600) / 60
        let secs = remaining % 60
        print("\r⏱️  Jiggling... (\(time)) — \(String(format: "%02d:%02d:%02d", hrs, mins, secs)) remaining   ", terminator: "")
    } else {
        print("\r⏱️  Jiggling... (\(time))", terminator: "")
    }
    fflush(stdout)
}
SWIFTEOF

swift "$SWIFT_TMP" "$DURATION"
