import AppKit
import SwiftUI

extension PetDefinition {
    static let bear = PetDefinition(
        foodKey: "honey",
        color: Color(red: 0.56, green: 0.35, blue: 0.22),
        menuColor: NSColor(calibratedRed: 0.56, green: 0.35, blue: 0.22, alpha: 1),
        menuPixels: [
            PetPixel(1, 2, color: .fur), PetPixel(6, 2, color: .fur),
            PetPixel(2, 2, color: .fur), PetPixel(5, 2, color: .fur),
            PetPixel(1, 3, color: .fur), PetPixel(6, 3, color: .fur),
            PetPixel(1, 4, color: .fur), PetPixel(6, 4, color: .fur),
            PetPixel(2, 5, color: .fur), PetPixel(3, 5, color: .fur),
            PetPixel(4, 5, color: .fur), PetPixel(5, 5, color: .fur),
            PetPixel(2, 6, color: .fur), PetPixel(3, 6, color: .fur),
            PetPixel(4, 6, color: .fur), PetPixel(5, 6, color: .fur),
            PetPixel(3, 7, color: .fur), PetPixel(4, 7, color: .fur)
        ],
        bodyPixels: [
            PetPixel(2, 2, 2, 2, color: .fur), PetPixel(12, 2, 2, 2, color: .fur),
            PetPixel(3, 2, color: .cream), PetPixel(12, 2, color: .cream),
            PetPixel(3, 3, 10, 1, color: .fur), PetPixel(2, 4, 12, 2, color: .fur),
            PetPixel(3, 6, 10, 1, color: .fur), PetPixel(4, 7, 8, 3, color: .fur),
            PetPixel(4, 10, 2, 1, color: .cream), PetPixel(10, 10, 2, 1, color: .cream),
            PetPixel(13, 9, 2, 1, color: .fur), PetPixel(15, 8, color: .fur)
        ]
    )
}
