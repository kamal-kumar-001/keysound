import AppKit
import ImageIO

guard CommandLine.arguments.count > 1 else {
    print("Usage: create-app-icon <output_directory>")
    exit(1)
}

let outputDirectory = CommandLine.arguments[1]
let fileManager = FileManager.default
try fileManager.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true)

let sizes: [(String, CGFloat)] = [
    ("16x16", 16), ("16x16@2x", 32),
    ("32x32", 32), ("32x32@2x", 64),
    ("128x128", 128), ("128x128@2x", 256),
    ("256x256", 256), ("256x256@2x", 512),
    ("512x512", 512), ("512x512@2x", 1024)
]

for (name, size) in sizes {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    // Rich Dark Graphite / Indigo Keycap Background
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let path = NSBezierPath(roundedRect: rect, xRadius: size * 0.22, yRadius: size * 0.22)
    
    let gradient = NSGradient(
        starting: NSColor(calibratedRed: 0.14, green: 0.16, blue: 0.24, alpha: 1.0),
        ending: NSColor(calibratedRed: 0.08, green: 0.09, blue: 0.14, alpha: 1.0)
    )
    gradient?.draw(in: path, angle: -45)

    // Subtle inner glow border
    NSColor(calibratedWhite: 1.0, alpha: 0.12).setStroke()
    path.lineWidth = max(1.0, size * 0.02)
    path.stroke()

    // Symbol: keyboard.fill
    if let symbol = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: nil) {
        let symbolSize = size * 0.54
        let symbolRect = NSRect(
            x: (size - symbolSize) / 2,
            y: (size - symbolSize) / 2,
            width: symbolSize,
            height: symbolSize
        )
        NSColor(calibratedRed: 0.35, green: 0.65, blue: 1.0, alpha: 1.0).set()
        symbol.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    image.unlockFocus()

    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
          let destination = CGImageDestinationCreateWithURL(
              URL(fileURLWithPath: "\(outputDirectory)/icon_\(name).png") as CFURL,
              "public.png" as CFString,
              1,
              nil
          ) else {
        exit(1)
    }

    CGImageDestinationAddImage(destination, cgImage, nil)
    CGImageDestinationFinalize(destination)
}
