import SwiftUI
import AppKit

struct MenuPetIcon: View {
    let kind: PetKind; let mood: Int; let frame: Bool

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
        let fur: NSColor = switch kind {
        case .cat: NSColor(calibratedRed: 0.98, green: 0.66, blue: 0.36, alpha: 1)
        case .rabbit: .systemPink
        case .bear: NSColor(calibratedRed: 0.56, green: 0.35, blue: 0.22, alpha: 1)
        }
        let dark = NSColor(calibratedRed: 0.16, green: 0.11, blue: 0.16, alpha: 1)
        func pixel(_ x: Int, _ y: Int, _ color: NSColor) {
            color.setFill()
            NSBezierPath(rect: NSRect(x: x * 2, y: (8 - y) * 2, width: 2, height: 2)).fill()
        }
        // An 8×8 native bitmap keeps the menu-bar art crisp at Retina scale.
        [(2,2),(5,2),(1,3),(6,3),(1,4),(6,4),(2,5),(3,5),(4,5),(5,5),(2,6),(3,6),(4,6),(5,6),(3,7),(4,7)].forEach { pixel($0.0, $0.1, fur) }
        switch kind {
        case .cat: pixel(2, 1, dark); pixel(5, 1, dark)
        case .rabbit:
            pixel(2, 0, fur); pixel(5, 0, fur); pixel(2, 1, fur); pixel(5, 1, fur)
        case .bear: pixel(1, 2, fur); pixel(6, 2, fur)
        }
        pixel(2, 3, dark); pixel(5, 3, dark); pixel(3, 4, dark)
        if happy { pixel(4, 4, dark) } else { pixel(3, 5, dark); pixel(4, 5, dark) }
        pixel(frame ? 6 : 7, 6, fur)
        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}

struct PixelPet: View {
    let kind: PetKind; let mood: Int; let hungry, sleepy, frame: Bool
    private var fur: Color { kind.color }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width / 16, geo.size.height / 12)
            let x = (geo.size.width - 16 * u) / 2, y = (geo.size.height - 12 * u) / 2
            Canvas { context, _ in
                func p(_ px: Int, _ py: Int, _ w: Int = 1, _ h: Int = 1, _ color: Color) {
                    context.fill(Path(CGRect(x: x + CGFloat(px) * u, y: y + CGFloat(py) * u, width: CGFloat(w) * u, height: CGFloat(h) * u)), with: .color(color))
                }
                let dark = Color(red: 0.20, green: 0.12, blue: 0.17), cream = Color(red: 1, green: 0.84, blue: 0.57)
                [(3,2),(4,2),(11,2),(12,2),(2,3),(13,3),(2,4),(13,4),(3,5),(12,5),(3,6),(12,6),(4,7),(5,7),(6,7),(7,7),(8,7),(9,7),(10,7),(5,8),(6,8),(7,8),(8,8),(9,8),(10,8),(4,9),(5,9),(6,9),(7,9),(8,9),(9,9),(10,9),(11,9)].forEach { p($0.0, $0.1, 1, 1, fur) }
                if kind == .rabbit {
                    p(3, 0, 2, 4, fur); p(11, 0, 2, 4, fur); p(4, 0, 1, 3, cream); p(11, 0, 1, 3, cream)
                } else if kind == .bear {
                    p(2, 2, 2, 2, fur); p(12, 2, 2, 2, fur); p(3, 2, 1, 1, cream); p(12, 2, 1, 1, cream)
                } else {
                    p(3, 2, 2, 2, dark); p(11, 2, 2, 2, dark); p(4, 3, 1, 1, cream); p(11, 3, 1, 1, cream)
                }
                if sleepy { p(5, 5, 2, 1, dark); p(10, 5, 2, 1, dark) } else { p(5, 5, 1, 1, dark); p(10, 5, 1, 1, dark) }
                p(8, 6, 1, 1, dark)
                if hungry { p(7, 7, 2, 1, dark) } else if mood > 55 { p(7, 7, 1, 1, dark); p(9, 7, 1, 1, dark) } else { p(7, 8, 2, 1, dark) }
                p(4, 10, 2, 1, cream); p(10, 10, 2, 1, cream)
                p(frame ? 12 : 13, 9, 2, 1, fur); p(frame ? 14 : 15, 8, 1, 1, fur)
            }
        }
    }
}
