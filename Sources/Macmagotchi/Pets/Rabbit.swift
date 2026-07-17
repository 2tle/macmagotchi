import AppKit
import SwiftUI

extension PetDefinition {
    static let rabbit: PetDefinition = {
        let earsUp = [
            PetPixel(3, 0, 2, 4, color: .fur), PetPixel(11, 0, 2, 4, color: .fur),
            PetPixel(4, 0, 1, 3, color: .cream), PetPixel(11, 0, 1, 3, color: .cream)
        ]
        let earsTilted = [
            PetPixel(2, 0, 2, 4, color: .fur), PetPixel(12, 0, 2, 4, color: .fur),
            PetPixel(3, 0, 1, 3, color: .cream), PetPixel(12, 0, 1, 3, color: .cream)
        ]
        let tailUp = [PetPixel(13, 9, 2, 1, color: .fur), PetPixel(15, 8, color: .fur)]
        let tailDown = [PetPixel(13, 8, 2, 1, color: .fur), PetPixel(15, 9, color: .fur)]
        return PetDefinition(
            foodKey: "carrot",
            color: .pink,
            menuColor: .systemPink,
            menuPixels: [
                PetPixel(2, 0, color: .fur), PetPixel(5, 0, color: .fur),
                PetPixel(2, 1, color: .fur), PetPixel(5, 1, color: .fur),
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
                PetPixel(2, 3, 2, 2, color: .fur), PetPixel(12, 3, 2, 2, color: .fur),
                PetPixel(3, 5, 1, 2, color: .fur), PetPixel(12, 5, 1, 2, color: .fur),
                PetPixel(4, 7, 7, 1, color: .fur), PetPixel(5, 8, 6, 1, color: .fur),
                PetPixel(4, 9, 8, 1, color: .fur), PetPixel(4, 10, 2, 1, color: .cream),
                PetPixel(10, 10, 2, 1, color: .cream)
            ],
            animations: PetAnimations(
                idle: [
                    PetSpriteFrame(pixels: earsUp + tailUp),
                    PetSpriteFrame(pixels: earsTilted + tailDown),
                    PetSpriteFrame(pixels: earsUp + tailUp, blinks: true)
                ],
                walking: [
                    PetSpriteFrame(pixels: earsTilted + tailUp),
                    PetSpriteFrame(pixels: earsUp + tailDown)
                ]
            )
        )
    }()
}
