import AppKit
import SwiftUI

enum PetKind: String, CaseIterable, Codable {
    case cat, rabbit, bear

    var titleKey: String { rawValue }
    var definition: PetDefinition {
        switch self {
        case .cat: .cat
        case .rabbit: .rabbit
        case .bear: .bear
        }
    }
    var foodKey: String { definition.foodKey }
    var color: Color { definition.color }
}

struct PetDefinition {
    let foodKey: String
    let color: Color
    let menuColor: NSColor
    // Each pet owns every non-transparent pixel; later pixels draw on top.
    let menuPixels: [PetPixel]
    let bodyPixels: [PetPixel]
    let animations: PetAnimations
}

enum PetMotion {
    case idle, walking
}

struct PetAnimations {
    let idle: [PetSpriteFrame]
    let walking: [PetSpriteFrame]

    func frame(for motion: PetMotion, tick: Int) -> PetSpriteFrame {
        let frames = motion == .idle ? idle : walking
        return frames[tick % frames.count]
    }
}

struct PetSpriteFrame {
    let pixels: [PetPixel]
    var verticalOffset = 0
    var blinks = false
}

struct PetPixel {
    let column: Int
    let row: Int
    let width: Int
    let height: Int
    let color: PetPixelColor

    init(_ column: Int, _ row: Int, _ width: Int = 1, _ height: Int = 1, color: PetPixelColor) {
        self.column = column
        self.row = row
        self.width = width
        self.height = height
        self.color = color
    }
}

enum PetPixelColor {
    case fur, dark, cream

    func color(fur: Color, dark: Color, cream: Color) -> Color {
        switch self {
        case .fur: fur
        case .dark: dark
        case .cream: cream
        }
    }

    func nsColor(fur: NSColor, dark: NSColor, cream: NSColor) -> NSColor {
        switch self {
        case .fur: fur
        case .dark: dark
        case .cream: cream
        }
    }
}

struct SavedPet: Codable {
    let name: String
    let kind: PetKind?
    let hunger, mood, energy, affection: Int
    let date: Date
}
