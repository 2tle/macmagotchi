import AppKit
import QuartzCore
import SwiftUI

private let petAnimationInterval: TimeInterval = 0.55

struct MenuPetIcon: View {
    let kind: PetKind
    let mood: Int
    @State private var tick = 0

    var body: some View {
        Image(nsImage: PixelMenuImage.make(kind: kind, happy: mood > 55, tick: tick))
            .interpolation(.none)
            .frame(width: 18, height: 18)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(petAnimationInterval))
                    guard !Task.isCancelled else { return }
                    tick = (tick + 1) % 2
                }
            }
    }
}

@MainActor
private enum PixelMenuImage {
    private static let cache = NSCache<NSString, NSImage>()

    static func make(kind: PetKind, happy: Bool, tick: Int) -> NSImage {
        let key = "\(kind.rawValue)-\(happy)-\(tick % 2)" as NSString
        if let image = cache.object(forKey: key) { return image }

        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .none

        let definition = kind.definition
        let fur = definition.menuColor
        let dark = NSColor(calibratedRed: 0.16, green: 0.11, blue: 0.16, alpha: 1)
        func pixel(column: Int, row: Int, color: NSColor) {
            color.setFill()
            NSBezierPath(
                rect: NSRect(x: column * 2, y: (8 - row) * 2, width: 2, height: 2)
            ).fill()
        }

        definition.menuPixels.forEach { detail in
            pixel(
                column: detail.column,
                row: detail.row,
                color: detail.color.nsColor(fur: fur, dark: dark, cream: NSColor.white)
            )
        }
        pixel(column: 2, row: 3, color: dark)
        pixel(column: 5, row: 3, color: dark)
        pixel(column: 3, row: 4, color: dark)
        if happy {
            pixel(column: 4, row: 4, color: dark)
        } else {
            pixel(column: 3, row: 5, color: dark)
            pixel(column: 4, row: 5, color: dark)
        }
        pixel(column: tick.isMultiple(of: 2) ? 6 : 7, row: 6, color: fur)
        image.unlockFocus()
        image.isTemplate = false
        cache.setObject(image, forKey: key)
        return image
    }
}

private struct AnimatedLayerView: NSViewRepresentable {
    let frames: [NSImage]
    let key: String

    final class Coordinator {
        var key: String?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layerContentsRedrawPolicy = .never
        view.layer?.contentsGravity = .resizeAspect
        view.layer?.magnificationFilter = .nearest
        view.layer?.minificationFilter = .nearest
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        guard context.coordinator.key != key,
              let layer = view.layer else { return }
        let images = frames.compactMap { $0.cgImage(forProposedRect: nil, context: nil, hints: nil) }
        guard let first = images.first, images.count == frames.count else { return }
        context.coordinator.key = key
        layer.removeAnimation(forKey: "pixelFrames")
        layer.contents = first
        guard images.count > 1 else { return }

        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.values = images + [first]
        animation.keyTimes = (0...images.count).map { NSNumber(value: Double($0) / Double(images.count)) }
        animation.calculationMode = .discrete
        animation.duration = petAnimationInterval * Double(images.count)
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "pixelFrames")
    }

    static func dismantleNSView(_ view: NSView, coordinator: Coordinator) {
        view.layer?.removeAnimation(forKey: "pixelFrames")
    }
}

struct AnimatedPixelPet: View {
    let kind: PetKind
    let mood: Int
    let hungry: Bool
    let sleepy: Bool
    let motion: PetMotion

    var body: some View {
        AnimatedLayerView(
            frames: (0..<6).map {
                PixelPetImage.make(
                    kind: kind, mood: mood, hungry: hungry, sleepy: sleepy, motion: motion, tick: $0
                )
            },
            key: "pet-\(kind.rawValue)-\(mood > 55)-\(hungry)-\(sleepy)-\(motion == .idle)"
        )
    }
}

struct PixelPet: View {
    let kind: PetKind
    let mood: Int
    let hungry: Bool
    let sleepy: Bool
    let motion: PetMotion
    let tick: Int

    var body: some View {
        Image(nsImage: PixelPetImage.make(
            kind: kind, mood: mood, hungry: hungry, sleepy: sleepy, motion: motion, tick: tick
        ))
        .resizable()
        .interpolation(.none)
        .aspectRatio(4 / 3, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
private enum PixelPetImage {
    private static let cache = NSCache<NSString, NSImage>()

    static func make(
        kind: PetKind,
        mood: Int,
        hungry: Bool,
        sleepy: Bool,
        motion: PetMotion,
        tick: Int
    ) -> NSImage {
        let motionKey = motion == .idle ? "idle" : "walking"
        let key = "\(kind.rawValue)-\(mood > 55)-\(hungry)-\(sleepy)-\(motionKey)-\(tick % 6)" as NSString
        if let image = cache.object(forKey: key) { return image }

        let image = NSImage(size: NSSize(width: 16, height: 12))
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .none
        let definition = kind.definition
        let sprite = definition.animations.frame(for: motion, tick: tick)
        let fur = definition.menuColor
        let dark = NSColor(calibratedRed: 0.20, green: 0.12, blue: 0.17, alpha: 1)
        let cream = NSColor(calibratedRed: 1, green: 0.84, blue: 0.57, alpha: 1)

        func pixel(
            column: Int,
            row: Int,
            width: Int = 1,
            height: Int = 1,
            color: NSColor
        ) {
            color.setFill()
            NSBezierPath(
                rect: NSRect(
                    x: column,
                    y: 12 - row - sprite.verticalOffset - height,
                    width: width,
                    height: height
                )
            ).fill()
        }

        (definition.bodyPixels + sprite.pixels).forEach { detail in
            pixel(
                column: detail.column,
                row: detail.row,
                width: detail.width,
                height: detail.height,
                color: detail.color.nsColor(fur: fur, dark: dark, cream: cream)
            )
        }
        if sleepy || sprite.blinks {
            pixel(column: 5, row: 5, width: 2, color: dark)
            pixel(column: 10, row: 5, width: 2, color: dark)
        } else {
            pixel(column: 5, row: 5, color: dark)
            pixel(column: 10, row: 5, color: dark)
        }
        pixel(column: 8, row: 6, color: dark)
        if hungry {
            pixel(column: 7, row: 7, width: 2, color: dark)
        } else if mood > 55 {
            pixel(column: 7, row: 7, color: dark)
            pixel(column: 9, row: 7, color: dark)
        } else {
            pixel(column: 7, row: 8, width: 2, color: dark)
        }

        image.unlockFocus()
        image.isTemplate = false
        cache.setObject(image, forKey: key)
        return image
    }
}
