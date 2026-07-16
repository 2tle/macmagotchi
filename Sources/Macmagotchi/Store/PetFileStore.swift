import Foundation

enum PetFileStore {
    static let fileURL: URL = {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Macmagotchi", isDirectory: true)
        return folder.appendingPathComponent("pet.json")
    }()

    static func load() -> SavedPet? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(SavedPet.self, from: data)
    }

    static func save(_ pet: SavedPet) {
        guard let data = try? JSONEncoder().encode(pet) else { return }
        try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: fileURL, options: .atomic)
    }
}
