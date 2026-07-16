import SwiftUI

enum PetKind: String, CaseIterable, Codable {
    case cat, rabbit, bear

    var titleKey: String { rawValue }
    var foodKey: String { switch self { case .cat: "tuna"; case .rabbit: "carrot"; case .bear: "honey" } }
    var color: Color {
        switch self {
        case .cat: Color(red: 0.98, green: 0.66, blue: 0.36)
        case .rabbit: .pink
        case .bear: Color(red: 0.56, green: 0.35, blue: 0.22)
        }
    }
}

struct SavedPet: Codable {
    let name: String
    let kind: PetKind?
    let hunger, mood, energy, affection: Int
    let date: Date
}
