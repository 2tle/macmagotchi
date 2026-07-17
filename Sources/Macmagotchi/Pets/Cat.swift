import AppKit
import SwiftUI

extension PetDefinition {
    static let cat: PetDefinition = {
        let ears = [PetPixel(3, 2, 2, 2, color: .dark), PetPixel(11, 2, 2, 2, color: .dark)]
        let tailUp = [PetPixel(13, 9, 2, 1, color: .fur), PetPixel(15, 8, color: .fur)]
        let tailDown = [PetPixel(13, 8, 2, 1, color: .fur), PetPixel(15, 9, color: .fur)]
        return PetDefinition(
            foodKey: "tuna",
            color: Color(red: 0.98, green: 0.66, blue: 0.36),
            menuColor: NSColor(calibratedRed: 0.98, green: 0.66, blue: 0.36, alpha: 1),
            menuPixels: [
                PetPixel(2, 2, color: .fur), PetPixel(5, 2, color: .fur),
                PetPixel(1, 3, color: .fur), PetPixel(6, 3, color: .fur),
                PetPixel(1, 4, color: .fur), PetPixel(6, 4, color: .fur),
                PetPixel(2, 5, color: .fur), PetPixel(3, 5, color: .fur),
                PetPixel(4, 5, color: .fur), PetPixel(5, 5, color: .fur),
                PetPixel(2, 6, color: .fur), PetPixel(3, 6, color: .fur),
                PetPixel(4, 6, color: .fur), PetPixel(5, 6, color: .fur),
                PetPixel(3, 7, color: .fur), PetPixel(4, 7, color: .fur),
                PetPixel(2, 1, color: .dark), PetPixel(5, 1, color: .dark)
            ],
            bodyPixels: [
                PetPixel(2, 3, 2, 2, color: .fur), PetPixel(12, 3, 2, 2, color: .fur),
                PetPixel(3, 5, 1, 2, color: .fur), PetPixel(12, 5, 1, 2, color: .fur),
                PetPixel(4, 7, 7, 1, color: .fur), PetPixel(5, 8, 6, 1, color: .fur),
                PetPixel(4, 9, 8, 1, color: .fur), PetPixel(4, 3, color: .cream),
                PetPixel(11, 3, color: .cream), PetPixel(4, 10, 2, 1, color: .cream),
                PetPixel(10, 10, 2, 1, color: .cream)
            ],
            animations: PetAnimations(
                idle: [
                    PetSpriteFrame(pixels: ears + tailUp),
                    PetSpriteFrame(pixels: ears + tailDown),
                    PetSpriteFrame(pixels: ears + tailUp, blinks: true)
                ],
                walking: [
                    PetSpriteFrame(pixels: ears + tailUp),
                    PetSpriteFrame(pixels: ears + tailDown, verticalOffset: -1)
                ]
            )
        )
    }()
}
