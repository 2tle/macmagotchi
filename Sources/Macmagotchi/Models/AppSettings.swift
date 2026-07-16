import SwiftUI

enum PetTask: String, CaseIterable, Identifiable {
    case pet, play, feed, sleep
    var id: String { rawValue }
    var titleKey: String { "\(rawValue)Button" }
    var icon: String { switch self { case .pet: "hand.tap.fill"; case .play: "sparkles"; case .feed: "fish.fill"; case .sleep: "moon.zzz.fill" } }
    var tint: Color { switch self { case .pet: .mint; case .play: .pink; case .feed: .orange; case .sleep: .indigo } }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case light, dark, pastel
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var scheme: ColorScheme { self == .light ? .light : .dark }
    var foreground: Color { self == .light ? Color(red: 0.08, green: 0.08, blue: 0.10) : .white }
    var secondary: Color { self == .light ? Color(red: 0.25, green: 0.25, blue: 0.28) : .white.opacity(0.7) }
    var panel: Color { self == .light ? .black.opacity(0.06) : .white.opacity(0.12) }
    var background: [Color] { switch self {
    case .light: [.white, Color(red: 0.93, green: 0.96, blue: 1)]
    case .dark: [Color(red: 0.11, green: 0.11, blue: 0.12), Color(red: 0.18, green: 0.19, blue: 0.22)]
    case .pastel: [Color(red: 0.20, green: 0.18, blue: 0.38), Color(red: 0.10, green: 0.23, blue: 0.36)]
    } }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en", korean = "ko"
    var id: String { rawValue }
    var title: String { self == .english ? "English" : "한국어" }
}

@MainActor
final class AppSettings: ObservableObject {
    @Published var language: AppLanguage { didSet { UserDefaults.standard.set(language.rawValue, forKey: "language") } }
    @Published var theme: AppTheme { didSet { UserDefaults.standard.set(theme.rawValue, forKey: "theme") } }
    @Published var petMinutes: Int { didSet { UserDefaults.standard.set(petMinutes, forKey: "petMinutes") } }
    @Published var playMinutes: Int { didSet { UserDefaults.standard.set(playMinutes, forKey: "playMinutes") } }
    @Published var feedMinutes: Int { didSet { UserDefaults.standard.set(feedMinutes, forKey: "feedMinutes") } }
    @Published var sleepMinutes: Int { didSet { UserDefaults.standard.set(sleepMinutes, forKey: "sleepMinutes") } }

    init() { theme = AppTheme(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "pastel") ?? .pastel; petMinutes = UserDefaults.standard.object(forKey: "petMinutes") as? Int ?? 10; playMinutes = UserDefaults.standard.object(forKey: "playMinutes") as? Int ?? 30; feedMinutes = UserDefaults.standard.object(forKey: "feedMinutes") as? Int ?? 60; sleepMinutes = UserDefaults.standard.object(forKey: "sleepMinutes") as? Int ?? 180; language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "language") ?? "en") ?? .english }
    func t(_ key: String) -> String { strings[language]?[key] ?? key }
    func minutes(_ task: PetTask) -> Int { switch task { case .pet: petMinutes; case .play: playMinutes; case .feed: feedMinutes; case .sleep: sleepMinutes } }
    func minutesBinding(_ task: PetTask) -> Binding<Int> { Binding(get: { self.minutes(task) }, set: { switch task { case .pet: self.petMinutes = $0; case .play: self.playMinutes = $0; case .feed: self.feedMinutes = $0; case .sleep: self.sleepMinutes = $0 } }) }

    private let strings: [AppLanguage: [String: String]] = [
        .english: [
            "idle": "Watching the world go by", "newDay": "A new day begins!", "feed": "Yum! %{food} is the best.", "play": "Hop, hop! This is fun!", "sleep": "Taking a cozy nap", "pet": "Purr… that feels nice!",
            "level": "Lv. %{level} · %{stage}", "hunger": "Hunger", "mood": "Mood", "energy": "Energy", "affection": "Bond", "feedButton": "Feed", "playButton": "Play", "sleepButton": "Sleep", "petButton": "Pet", "settings": "Settings", "newPet": "New pet", "quit": "Quit Macmagotchi", "welcome": "Welcome!", "chooseFriend": "Choose your new friend", "namePlaceholder": "Name (e.g. Mochi)", "adopt": "Adopt %{kind}", "records": "%{name}'s record", "bondProgress": "Bond %{value} / 125", "growthHint": "Grow at bond levels 45 and 100.", "decayHint": "Stats decrease a little every 30 minutes.", "language": "Language", "resetPet": "Reset pet", "resetTitle": "Reset this pet?", "resetMessage": "Your current pet data will be erased.", "cancel": "Cancel", "reset": "Reset", "baby": "Baby %{kind}", "growing": "Growing up", "grown": "Grown %{kind}", "cat": "Cat", "rabbit": "Rabbit", "bear": "Bear", "tuna": "tuna", "carrot": "carrots", "honey": "honey"],
        .korean: [
            "idle": "창밖을 구경하고 있어요", "newDay": "새로운 하루가 시작됐어요!", "feed": "냠냠! %{food}가 최고예요", "play": "폴짝폴짝, 신나요!", "sleep": "포근하게 낮잠을 자요", "pet": "골골… 기분이 좋아요", "level": "Lv. %{level} · %{stage}", "hunger": "배고픔", "mood": "기분", "energy": "체력", "affection": "친밀도", "feedButton": "밥 주기", "playButton": "놀아주기", "sleepButton": "재우기", "petButton": "쓰담", "settings": "설정", "newPet": "새 펫 설정", "quit": "맥마고치 종료", "welcome": "반가워요!", "chooseFriend": "함께할 친구를 골라주세요", "namePlaceholder": "이름 (예: 모찌)", "adopt": "%{kind} 가족 맞이하기", "records": "%{name}의 기록", "bondProgress": "친밀도 %{value} / 125", "growthHint": "친밀도가 45, 100이 되면 성장해요.", "decayHint": "매 30분마다 상태가 조금씩 줄어요.", "language": "언어", "resetPet": "펫 초기화", "resetTitle": "펫을 초기화할까요?", "resetMessage": "현재 펫 데이터가 모두 삭제됩니다.", "cancel": "취소", "reset": "초기화", "baby": "아기 %{kind}", "growing": "무럭무럭 성장 중", "grown": "다 큰 %{kind}", "cat": "고양이", "rabbit": "토끼", "bear": "곰", "tuna": "참치", "carrot": "당근", "honey": "꿀"]
    ]
}

extension AppSettings {
    func t(_ key: String, _ values: [String: String]) -> String {
        values.reduce(t(key)) { $0.replacingOccurrences(of: "%{\($1.key)}", with: $1.value) }
    }
}
