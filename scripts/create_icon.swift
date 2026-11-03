// Draw a small, original fan mark using Apple's Core Graphics APIs.
// Run: swift scripts/create_icon.swift
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let size = 1024
guard let context = CGContext(
    data: nil, width: size, height: size, bitsPerComponent: 8,
    bytesPerRow: size * 4, space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { fatalError("Could not create icon canvas") }

let colors = [
    CGColor(red: 0.10, green: 0.48, blue: 0.47, alpha: 1),
    CGColor(red: 0.04, green: 0.31, blue: 0.34, alpha: 1)
] as CFArray
if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 1024), end: .zero, options: [])
}

context.translateBy(x: 512, y: 512)
context.setFillColor(CGColor(red: 0.94, green: 0.98, blue: 0.96, alpha: 1))
for _ in 0..<3 {
    context.beginPath()
    context.move(to: CGPoint(x: 20, y: 25))
    context.addCurve(to: CGPoint(x: 210, y: 310), control1: CGPoint(x: -95, y: 210), control2: CGPoint(x: 40, y: 390))
    context.addCurve(to: CGPoint(x: 255, y: 125), control1: CGPoint(x: 320, y: 245), control2: CGPoint(x: 335, y: 170))
    context.addCurve(to: CGPoint(x: 20, y: 25), control1: CGPoint(x: 180, y: 95), control2: CGPoint(x: 90, y: 80))
    context.fillPath()
    context.rotate(by: .pi * 2 / 3)
}
context.fillEllipse(in: CGRect(x: -57, y: -57, width: 114, height: 114))

let output = URL(filePath: FileManager.default.currentDirectoryPath)
    .appending(path: "Breeze/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
guard let image = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Could not create icon file")
}
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("Could not save icon") }
print("Created \(output.path())")
