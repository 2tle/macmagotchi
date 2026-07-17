import SwiftUI
import UserNotifications

@MainActor
final class PetStore: ObservableObject {
    @Published var name = "Mochi"
    @Published var kind: PetKind = .cat
    @Published var isOnboarding = true
    @Published var hunger = 76
    @Published var mood = 82
    @Published var energy = 68
    @Published var affection = 31
    @Published var animationTick = 0
    @Published var lastAction = "idle"
    @Published var activeTask: PetTask?
    @Published var secondsRemaining = 0
    @Published var focusTotalSeconds = 0

    private var timer: Timer?
    private var animationTimer: Timer?
    private var lastNotice = Date.distantPast
    private var focusTimer: Timer?

    init() {
        load()
        applyElapsedTime()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.animationTick = (self.animationTick + 1) % 6
            }
        }
        requestNotifications()
        DispatchQueue.main.async { DesktopPetController.shared.show(pet: self) }
    }

    func stage(_ settings: AppSettings) -> String {
        affection >= 100 ? settings.t("grown", ["kind": settings.t(kind.titleKey)]) :
            affection >= 45 ? settings.t("growing") : settings.t("baby", ["kind": settings.t(kind.titleKey)])
    }
    var level: Int { min(5, affection / 25 + 1) }
    var isSleepy: Bool { energy < 30 }
    var isHungry: Bool { hunger < 30 }

    func beginOnboarding() { isOnboarding = true }

    func start(name: String, kind: PetKind) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = trimmedName.isEmpty ? "Mochi" : trimmedName
        self.kind = kind
        hunger = 76; mood = 82; energy = 68; affection = 0
        isOnboarding = false
        lastAction = "newDay"
        save()
    }

    var isFocusing: Bool { activeTask != nil }
    func begin(_ task: PetTask, minutes: Int) {
        guard activeTask == nil else { return }
        activeTask = task; secondsRemaining = minutes * 60; focusTotalSeconds = secondsRemaining
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in Task { @MainActor in self?.advanceFocus() } }
    }
    private func advanceFocus() {
        secondsRemaining -= 1
        guard secondsRemaining <= 0, let task = activeTask else { return }
        focusTimer?.invalidate(); focusTimer = nil; activeTask = nil
        switch task {
        case .feed: change(hunger: 24, mood: 5, affection: 2, message: "feed")
        case .play: change(hunger: -8, mood: 20, energy: -13, affection: 5, message: "play")
        case .sleep: change(hunger: -3, mood: 4, energy: 28, message: "sleep")
        case .pet: change(mood: 10, affection: 7, message: "pet")
        }
    }

    private func change(hunger: Int = 0, mood: Int = 0, energy: Int = 0, affection: Int = 0, message: String) {
        self.hunger = cap(self.hunger + hunger)
        self.mood = cap(self.mood + mood)
        self.energy = cap(self.energy + energy)
        self.affection = cap(self.affection + affection, max: 125)
        lastAction = message
        save()
    }

    private func tick() {
        hunger = cap(hunger - 2)
        energy = cap(energy - 1)
        mood = cap(mood - (hunger < 30 || energy < 25 ? 2 : 0))
        save()
        if (hunger < 20 || energy < 20), Date.now.timeIntervalSince(lastNotice) > 60 * 60 * 3 {
            notify(hunger < 20 ? "\(name)가 배고파요" : "\(name)가 졸려요", body: hunger < 20 ? "잠깐 들러서 밥을 주세요." : "조금 쉬게 해주세요.")
            lastNotice = .now
        }
    }

    private func cap(_ value: Int, max upperBound: Int = 100) -> Int { min(upperBound, Swift.max(0, value)) }
    private func load() {
        let filePet = PetFileStore.load()
        let legacyPet = UserDefaults.standard.data(forKey: "pet").flatMap { try? JSONDecoder().decode(SavedPet.self, from: $0) }
        guard let saved = filePet ?? legacyPet else { return }
        name = saved.name; kind = saved.kind ?? .cat; hunger = saved.hunger; mood = saved.mood; energy = saved.energy; affection = saved.affection
        isOnboarding = false
        if filePet == nil { PetFileStore.save(saved) }
    }
    private func applyElapsedTime() {
        guard let date = PetFileStore.load()?.date else { return }
        let periods = min(720, Int(Date.now.timeIntervalSince(date) / 1800))
        hunger = cap(hunger - periods * 2); energy = cap(energy - periods); mood = cap(mood - periods / 2)
        save()
    }
    private func save() {
        PetFileStore.save(SavedPet(name: name, kind: kind, hunger: hunger, mood: mood, energy: energy, affection: affection, date: .now))
    }

    // ponytail: SwiftPM runs outside an .app bundle; skip notifications there rather than crash.
    private var supportsNotifications: Bool { Bundle.main.bundleURL.pathExtension == "app" }
    private func requestNotifications() {
        guard supportsNotifications else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    func reset() {
        try? FileManager.default.removeItem(at: PetFileStore.fileURL)
        name = "Mochi"; kind = .cat; hunger = 76; mood = 82; energy = 68; affection = 0; lastAction = "idle"; isOnboarding = true
    }

    private func notify(_ title: String, body: String) {
        guard supportsNotifications else { return }
        let content = UNMutableNotificationContent(); content.title = title; content.body = body; content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "pet-needs", content: content, trigger: nil))
    }
}
