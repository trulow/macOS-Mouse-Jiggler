#!/bin/bash

# Mouse Jiggler - Keeps macOS active by moving the mouse 1px left/right every second
# No dependencies — uses Swift which ships with macOS Xcode Command Line Tools
# Usage: ./mouse_jiggler.sh
# Stop:  Ctrl+C

# Check for Xcode Command Line Tools (required for swift)
if ! command -v swift &>/dev/null; then
  echo "❌ Swift not found. Install Xcode Command Line Tools by running:"
  echo "   xcode-select --install"
  exit 1
fi

echo "🖱️  Mouse Jiggler started. Press Ctrl+C to stop."
echo ""

swift - <<'EOF'
import Foundation
import CoreGraphics

signal(SIGINT) { _ in
    print("\n🛑 Mouse Jiggler stopped.")
    exit(0)
}

var direction: CGFloat = 1.0

while true {
    Thread.sleep(forTimeInterval: 1.0)

    let loc = CGEvent(source: nil)?.location ?? CGPoint.zero
    let newPos = CGPoint(x: loc.x + direction, y: loc.y)
    let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                        mouseCursorPosition: newPos, mouseButton: .left)
    event?.post(tap: .cghidEventTap)
    direction *= -1.0

    let time = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    print("\r⏱️  Jiggling... (\(time))", terminator: "")
    fflush(stdout)
}
EOF
