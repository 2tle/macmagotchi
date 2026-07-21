import SwiftUI

@main
struct MacmagotchiApp: App {
    @StateObject private var pet = PetStore()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        MenuBarExtra {
            PetPopover(pet: pet, settings: settings).frame(width: 360)
        } label: {
            HStack(spacing: 3) {
                MenuPetIcon(kind: pet.kind, mood: pet.mood)
                if pet.isFocusing {
                    Text(String(format: "%02d:%02d", pet.secondsRemaining / 60, pet.secondsRemaining % 60))
                        .monospacedDigit()
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
