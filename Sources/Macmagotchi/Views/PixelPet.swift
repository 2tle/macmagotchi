import AppKit
import SwiftUI

struct MenuPetIcon: View {
    let kind: PetKind
    let mood: Int
    let frame: Bool

    var body: some View {
        Image(nsImage: PixelMenuImage.make(kind: kind, happy: mood > 55, frame: frame))
            .interpolation(.none)
            .frame(width: 18, height: 18)
    }
}

private enum PixelMenuImage {
    static func make(kind: PetKind, happy: Bool, frame: Bool) -> NSImage {
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
        pixel(column: frame ? 6 : 7, row: 6, color: fur)
        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}

struct PixelPet: View {
    let kind: PetKind
    let mood: Int
    let hungry: Bool
    let sleepy: Bool
    let frame: Bool

    private var fur: Color { kind.color }

    var body: some View {
        GeometryReader { geometry in
            let pixelSize = min(geometry.size.width / 16, geometry.size.height / 12)
            let originX = (geometry.size.width - 16 * pixelSize) / 2
            let originY = (geometry.size.height - 12 * pixelSize) / 2
            Canvas { context, _ in
                func pixel(column: Int, row: Int, width: Int = 1, height: Int = 1, color: Color) {
                    context.fill(
                        Path(
                            CGRect(
                                x: originX + CGFloat(column) * pixelSize,
                                y: originY + CGFloat(row) * pixelSize,
                                width: CGFloat(width) * pixelSize,
                                height: CGFloat(height) * pixelSize
                            )
                        ),
                        with: .color(color)
                    )
                }

                let dark = Color(red: 0.20, green: 0.12, blue: 0.17)
                let cream = Color(red: 1, green: 0.84, blue: 0.57)
                let definition = kind.definition
                definition.bodyPixels.forEach { detail in
                    pixel(
                        column: detail.column,
                        row: detail.row,
                        width: detail.width,
                        height: detail.height,
                        color: detail.color.color(fur: fur, dark: dark, cream: cream)
                    )
                }
                if sleepy {
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

            }
        }
    }
}
