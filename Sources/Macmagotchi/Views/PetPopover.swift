import SwiftUI
import AppKit

struct PetPopover: View {
    @ObservedObject var pet: PetStore
    @ObservedObject var settings: AppSettings
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            LinearGradient(colors: settings.theme.background, startPoint: .topLeading, endPoint: .bottomTrailing)
            if pet.isOnboarding {
                WelcomeView(pet: pet, settings: settings)
            } else {
                VStack(spacing: 15) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(pet.name).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(settings.theme.foreground)
                            Text(settings.t("level", ["level": "\(pet.level)", "stage": pet.stage(settings)])).font(.caption.weight(.medium)).foregroundStyle(settings.theme.secondary)
                        }
                        Spacer()
                        Button { showingSettings.toggle() } label: { Image(systemName: "gearshape.fill").font(.title3) }
                            .buttonStyle(.plain).foregroundStyle(settings.theme.secondary)
                            .popover(isPresented: $showingSettings) { SettingsView(pet: pet, settings: settings) }
                    }
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 22).fill(settings.theme.panel).overlay(alignment: .topTrailing) { Circle().fill(.white.opacity(0.45)).frame(width: 8).padding(18) }
                        PixelPet(kind: pet.kind, mood: pet.mood, hungry: pet.isHungry, sleepy: pet.isSleepy, frame: pet.frame)
                            .frame(width: 165, height: 125).padding(.bottom, 5)
                    }.frame(height: 145)
                    Text(settings.t(pet.lastAction, ["food": settings.t(pet.kind.foodKey)])).font(.subheadline.weight(.medium)).foregroundStyle(settings.theme.foreground).frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 10) {
                        StatRow(icon: "fork.knife", label: settings.t("hunger"), value: pet.hunger, tint: .orange, foreground: settings.theme.foreground, secondary: settings.theme.secondary)
                        StatRow(icon: "face.smiling", label: settings.t("mood"), value: pet.mood, tint: .pink, foreground: settings.theme.foreground, secondary: settings.theme.secondary)
                        StatRow(icon: "bolt.fill", label: settings.t("energy"), value: pet.energy, tint: .yellow, foreground: settings.theme.foreground, secondary: settings.theme.secondary)
                        StatRow(icon: "heart.fill", label: settings.t("affection"), value: min(100, pet.affection), tint: .mint, foreground: settings.theme.foreground, secondary: settings.theme.secondary)
                    }.padding(14).background(settings.theme.panel, in: RoundedRectangle(cornerRadius: 18))
                    if pet.isFocusing {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack { Text(timeString(pet.secondsRemaining)).font(.title2.monospacedDigit()); Spacer(); Text("Focus").font(.caption.weight(.semibold)) }
                            ProgressView(value: Double(pet.secondsRemaining), total: Double(pet.focusTotalSeconds)).tint(.mint)
                        }.foregroundStyle(settings.theme.foreground)
                    }
                    HStack(spacing: 8) {
                        ForEach(PetTask.allCases.sorted { settings.minutes($0) < settings.minutes($1) }) { task in
                            ActionButton(settings.t(task.titleKey), icon: task.icon, tint: task.tint, foreground: settings.theme.foreground) { pet.begin(task, minutes: settings.minutes(task)) }
                        }
                    }.disabled(pet.isFocusing)
                    Divider().overlay(settings.theme.secondary.opacity(0.3))
                    Button(settings.t("quit")) { NSApplication.shared.terminate(nil) }
                        .buttonStyle(.plain).font(.caption).foregroundStyle(settings.theme.secondary)
                }.padding(18)
            }
        }.clipShape(RoundedRectangle(cornerRadius: 25)).padding(6).preferredColorScheme(settings.theme.scheme)
    }
    private func timeString(_ seconds: Int) -> String { String(format: "%02d:%02d", seconds / 60, seconds % 60) }
}

struct WelcomeView: View {
    @ObservedObject var pet: PetStore
    @ObservedObject var settings: AppSettings
    @State private var name = ""
    @State private var kind: PetKind = .cat

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text(settings.t("welcome")).font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(settings.theme.foreground)
                Text(settings.t("chooseFriend")).font(.subheadline).foregroundStyle(settings.theme.secondary)
            }
            HStack(spacing: 10) {
                ForEach(PetKind.allCases, id: \.self) { option in
                    Button { kind = option } label: {
                        VStack(spacing: 6) {
                            PixelPet(kind: option, mood: 90, hungry: false, sleepy: false, frame: false).frame(height: 62)
                            Text(settings.t(option.titleKey)).font(.caption.weight(.bold))
                        }.frame(maxWidth: .infinity).padding(.vertical, 9)
                    }.buttonStyle(.plain).foregroundStyle(settings.theme.foreground)
                        .background(kind == option ? option.color.opacity(0.58) : .white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(kind == option ? 0.8 : 0), lineWidth: 1))
                }
            }
            TextField(settings.t("namePlaceholder"), text: $name).textFieldStyle(.plain).padding(12)
                .background(settings.theme.panel, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(settings.theme.foreground)
            Button(settings.t("adopt", ["kind": settings.t(kind.titleKey)])) { pet.start(name: name, kind: kind) }
                .buttonStyle(.plain).font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity).padding(13)
                .background(kind.color.opacity(0.75), in: RoundedRectangle(cornerRadius: 14))
        }.padding(22)
    }
}

struct StatRow: View {
    let icon, label: String; let value: Int; let tint, foreground, secondary: Color
    var body: some View { HStack(spacing: 8) { Image(systemName: icon).foregroundStyle(tint).frame(width: 16); Text(label).font(.caption.weight(.medium)).frame(width: 38, alignment: .leading).foregroundStyle(foreground); ProgressView(value: Double(value), total: 100).tint(tint); Text("\(value)").font(.caption.monospacedDigit()).foregroundStyle(secondary).frame(width: 24, alignment: .trailing) } }
}

struct ActionButton: View {
    let title, icon: String; let tint, foreground: Color; let action: () -> Void
    init(_ title: String, icon: String, tint: Color, foreground: Color, action: @escaping () -> Void) { self.title = title; self.icon = icon; self.tint = tint; self.foreground = foreground; self.action = action }
    var body: some View { Button(action: action) { VStack(spacing: 5) { Image(systemName: icon); Text(title).font(.caption2.weight(.semibold)) }.frame(maxWidth: .infinity).padding(.vertical, 9).contentShape(RoundedRectangle(cornerRadius: 13)) }.buttonStyle(.plain).foregroundStyle(foreground).background(tint.opacity(0.40), in: RoundedRectangle(cornerRadius: 13)) }
}

struct SettingsView: View {
    @ObservedObject var pet: PetStore
    @ObservedObject var settings: AppSettings
    @State private var confirmingReset = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(settings.t("settings")).font(.headline).padding(.bottom, 5)
            Menu {
                ForEach(AppLanguage.allCases) { language in
                    Button(language.title) { settings.language = language }
                }
            } label: {
                SettingsRow(icon: "globe", title: settings.t("language"), value: settings.language.title)
            }.menuStyle(.borderlessButton)
            Divider()
            Button {
                NSWorkspace.shared.open(URL(string: "https://github.com/2tle/macmagotchi")!)
            } label: {
                SettingsRow(icon: "link", title: "Visit GitHub")
            }.buttonStyle(.plain)
            Divider()
            Picker("Theme", selection: $settings.theme) { ForEach(AppTheme.allCases) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
            Divider()
            Text("Timer").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            ForEach(PetTask.allCases) { task in
                HStack {
                    Image(systemName: task.icon).frame(width: 18).foregroundStyle(task.tint)
                    Text(settings.t(task.titleKey))
                    Spacer()
                    Stepper("\(settings.minutes(task)) min", value: settings.minutesBinding(task), in: 5...480, step: 5).labelsHidden()
                    Text("\(settings.minutes(task))m").monospacedDigit().foregroundStyle(.secondary)
                }.padding(.vertical, 3)
            }
            Divider()
            if confirmingReset {
                Text(settings.t("resetMessage")).font(.caption).foregroundStyle(.secondary)
                HStack {
                    Button(settings.t("cancel")) { confirmingReset = false }
                    Spacer()
                    Button(settings.t("reset"), role: .destructive) { pet.reset(); confirmingReset = false }
                }
            } else {
                Button { confirmingReset = true } label: {
                    SettingsRow(icon: "arrow.counterclockwise", title: settings.t("resetPet"))
                }.buttonStyle(.plain)
            }
        }.padding().frame(width: 250)
    }
}

private struct SettingsRow: View {
    let icon: String; let title: String; var value: String? = nil
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).frame(width: 18).foregroundStyle(.secondary)
            Text(title)
            Spacer()
            if let value { Text(value).foregroundStyle(.secondary) }
            if value != nil { Image(systemName: "chevron.up.chevron.down").font(.caption2).foregroundStyle(.tertiary) }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 7).contentShape(Rectangle())
    }
}
