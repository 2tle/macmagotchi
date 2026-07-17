import AppKit
import SwiftUI

@MainActor
final class DesktopPetController {
    static let shared = DesktopPetController()
    private var panel: NSPanel?
    private var walkTimer: Timer?
    private var direction: CGFloat = 1
    private let usesLeftDockSide = Bool.random()
    // ponytail: Dock width is private API; increase this clearance for a wide Dock.
    private let dockClearance: CGFloat = 480

    func show(pet: PetStore) {
        guard UserDefaults.standard.object(forKey: "showsDesktopPet") as? Bool ?? true, panel == nil, let screen = NSScreen.main else { return }
        let view = NSHostingView(rootView: DesktopPetOverlay(pet: pet))
        let size = NSSize(width: 140, height: 130)
        let bounds = walkBounds(on: screen, petSize: size)
        let frame = NSRect(x: bounds.midX - size.width / 2, y: bounds.minY, width: size.width, height: size.height)
        let panel = NSPanel(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.contentView = view
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.orderFrontRegardless()
        self.panel = panel
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in Task { @MainActor in self?.walk() } }
    }

    func setVisible(_ visible: Bool, pet: PetStore) {
        if visible { show(pet: pet) } else { walkTimer?.invalidate(); walkTimer = nil; panel?.orderOut(nil); panel = nil }
    }

    private func walk() {
        guard let panel, let screen = panel.screen ?? NSScreen.main else { return }
        let bounds = walkBounds(on: screen, petSize: panel.frame.size)
        guard bounds.width >= panel.frame.width else { return }
        var frame = panel.frame
        frame.origin.x += direction * 1.2
        if frame.minX < bounds.minX || frame.maxX > bounds.maxX {
            direction *= -1
            frame.origin.x = min(max(frame.origin.x, bounds.minX), bounds.maxX - frame.width)
        }
        frame.origin.y = bounds.minY
        panel.setFrameOrigin(frame.origin)
    }

    private func walkBounds(on screen: NSScreen, petSize: NSSize) -> NSRect {
        let screenFrame = screen.frame
        guard screen.visibleFrame.minY > screenFrame.minY else { return screen.visibleFrame }
        let clearance = min(dockClearance, screenFrame.width * 0.45)
        let sideWidth = (screenFrame.width - clearance) / 2
        let originX = usesLeftDockSide ? screenFrame.minX : screenFrame.maxX - sideWidth
        return NSRect(x: originX, y: screenFrame.minY, width: sideWidth, height: petSize.height)
    }
}

private struct DesktopPetOverlay: View {
    @ObservedObject var pet: PetStore

    var body: some View {
        VStack(spacing: 2) {
            PixelPet(kind: pet.kind, mood: pet.mood, hungry: pet.isHungry, sleepy: pet.isSleepy || pet.isFocusing, motion: .walking, tick: pet.animationTick)
                .frame(width: 92, height: 80)
            Capsule().fill(.black.opacity(0.16)).frame(width: 74, height: 7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .contentShape(Rectangle())
    }
}
