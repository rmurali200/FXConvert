#!/usr/bin/env swift
// Generates the app icon from the same dollarsign.circle.fill SF Symbol used in the menu bar,
// rendered full-color (not a template image — that's specific to the menu bar glyph) on a
// rounded-square card. Run manually from the project root when the design changes:
//   swift Scripts/generate-icon.swift && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns
import AppKit

let iconSizes: [(name: String, pixels: Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024)
]

func renderIcon(pixels: Int) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let canvas = NSRect(x: 0, y: 0, width: pixels, height: pixels)

    // Rounded-square card background, matching the macOS Big Sur+ icon convention.
    let cornerRadius = CGFloat(pixels) * 0.225
    NSColor.white.setFill()
    NSBezierPath(roundedRect: canvas, xRadius: cornerRadius, yRadius: cornerRadius).fill()

    // Centered dollar-sign glyph, tinted green.
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: CGFloat(pixels) * 0.66, weight: .heavy)
        .applying(NSImage.SymbolConfiguration(hierarchicalColor: .systemGreen))
    if let symbol = NSImage(systemSymbolName: "dollarsign.circle.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(symbolConfig) {
        let symbolSize = symbol.size
        let origin = NSPoint(
            x: (CGFloat(pixels) - symbolSize.width) / 2,
            y: (CGFloat(pixels) - symbolSize.height) / 2
        )
        symbol.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let iconsetDir = URL(fileURLWithPath: "Resources/AppIcon.iconset")
try? FileManager.default.removeItem(at: iconsetDir)
try! FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

for (name, pixels) in iconSizes {
    guard let data = renderIcon(pixels: pixels).representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode \(name)")
    }
    try! data.write(to: iconsetDir.appendingPathComponent("\(name).png"))
}

// Large preview at the project root, to eyeball before/after regenerating the .icns.
if let data = renderIcon(pixels: 1024).representation(using: .png, properties: [:]) {
    try! data.write(to: URL(fileURLWithPath: "icon_preview.png"))
}

print("Wrote \(iconsetDir.path) and icon_preview.png")
