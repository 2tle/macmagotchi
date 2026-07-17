import AppKit
import SwiftUI

extension PetDefinition {
    static let bear: PetDefinition = {
        let earsUp = [
            PetPixel(2, 2, 2, 2, color: .fur), PetPixel(12, 2, 2, 2, color: .fur),
            PetPixel(3, 2, color: .cream), PetPixel(12, 2, color: .cream)
        ]
        let earsDown = [
            PetPixel(2, 1, 2, 2, color: .fur), PetPixel(12, 1, 2, 2, color: .fur),
            PetPixel(3, 1, color: .cream), PetPixel(12, 1, color: .cream)
        ]
        let tailUp = [PetPixel(13, 9, 2, 1, color: .fur), PetPixel(15, 8, color: .fur)]
        let tailDown = [PetPixel(13, 8, 2, 1, color: .fur), PetPixel(15, 9, color: .fur)]
        return PetDefinition(
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
            PetPixel(3, 3, 10, 1, color: .fur), PetPixel(2, 4, 12, 2, color: .fur),
            PetPixel(3, 6, 10, 1, color: .fur), PetPixel(4, 7, 8, 3, color: .fur),
            PetPixel(4, 10, 2, 1, color: .cream), PetPixel(10, 10, 2, 1, color: .cream)
        ],
        animations: PetAnimations(
            idle: [
                PetSpriteFrame(pixels: earsUp + tailUp),
                PetSpriteFrame(pixels: earsDown + tailDown),
                PetSpriteFrame(pixels: earsUp + tailUp, blinks: true)
            ],
            walking: [
                PetSpriteFrame(pixels: earsDown + tailUp),
                PetSpriteFrame(pixels: earsUp + tailDown, verticalOffset: -1)
            ]
        )
        )
    }()
}
