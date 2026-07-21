import AppKit
import QuartzCore
import SwiftUI

@MainActor
final class DesktopPetController {
    static let shared = DesktopPetController()
    private var panel: NSPanel?
    private var petView: NSView?
    private var screenObserver: NSObjectProtocol?
    private var direction: CGFloat = 1
    private var position: DesktopPetPosition = .bottomRight

    private init() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.panel != nil, self.position != .fixed else { return }
                self.setPosition(self.position)
            }
        }
    }

    func show(pet: PetStore) {
        guard UserDefaults.standard.object(forKey: "showsDesktopPet") as? Bool ?? true,
              panel == nil,
              let screen = NSScreen.main else { return }
        position = DesktopPetPosition(
            rawValue: UserDefaults.standard.string(forKey: "desktopPetPosition") ?? "bottomRight"
        ) ?? .bottomRight
        #if DEBUG
        Self.validateMovementBounds()
        #endif
        let size = NSSize(width: 140, height: 130)
        let frame = Self.movementBounds(in: screen.visibleFrame, petSize: size, position: position)
        let panel = NSPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        let container = NSView(frame: NSRect(origin: .zero, size: frame.size))
        let petView = NSHostingView(rootView: DesktopPetOverlay(pet: pet))
        petView.frame = NSRect(
            x: position == .fixed ? 0 : (frame.width - size.width) / 2,
            y: 0,
            width: size.width,
            height: size.height
        )
        petView.wantsLayer = true
        container.wantsLayer = true
        container.addSubview(petView)
        panel.contentView = container
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.ignoresMouseEvents = position != .fixed
        panel.isMovableByWindowBackground = position == .fixed
        panel.orderFrontRegardless()
        self.panel = panel
        self.petView = petView
        direction = position == .topLeft || position == .bottomLeft ? 1 : -1
        if position != .fixed { startWalking() }
    }

    func setVisible(_ visible: Bool, pet: PetStore) {
        if visible {
            show(pet: pet)
        } else {
            stopWalking()
            panel?.orderOut(nil)
            petView = nil
            panel = nil
        }
    }

    func setPosition(_ position: DesktopPetPosition) {
        let currentPetOrigin = petScreenOrigin()
        stopWalking()
        self.position = position
        guard let panel, let petView else { return }
        panel.ignoresMouseEvents = position != .fixed
        panel.isMovableByWindowBackground = position == .fixed

        let size = NSSize(width: 140, height: 130)
        if position == .fixed {
            panel.setFrame(NSRect(origin: currentPetOrigin ?? panel.frame.origin, size: size), display: true)
            petView.frame = NSRect(origin: .zero, size: size)
            return
        }

        guard let screen = panel.screen ?? NSScreen.main else { return }
        let bounds = Self.movementBounds(in: screen.visibleFrame, petSize: size, position: position)
        panel.setFrame(bounds, display: true)
        petView.frame = NSRect(x: (bounds.width - size.width) / 2, y: 0, width: size.width, height: size.height)
        direction = position == .topLeft || position == .bottomLeft ? 1 : -1
        startWalking()
    }

    private func startWalking() {
        guard position != .fixed,
              let panel,
              let petView,
              let layer = petView.layer else { return }
        let minX = petView.frame.width / 2
        let maxX = (panel.contentView?.bounds.width ?? panel.frame.width) - minX
        let distance = maxX - minX
        guard distance > 0 else { return }

        let currentX = min(max(petView.frame.midX, minX), maxX)
        let oneWayDuration = TimeInterval(distance / 30)
        let phase = direction > 0
            ? TimeInterval((currentX - minX) / 30)
            : oneWayDuration + TimeInterval((maxX - currentX) / 30)
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [minX, maxX, minX]
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .linear),
            CAMediaTimingFunction(name: .linear)
        ]
        animation.duration = oneWayDuration * 2
        animation.repeatCount = .greatestFiniteMagnitude
        animation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        animation.timeOffset = phase
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "walking")
    }

    private func stopWalking() {
        petView?.layer?.removeAnimation(forKey: "walking")
    }

    private func petScreenOrigin() -> NSPoint? {
        guard let panel, let petView else { return nil }
        let frame = petView.layer?.presentation()?.frame ?? petView.frame
        return NSPoint(x: panel.frame.minX + frame.minX, y: panel.frame.minY + frame.minY)
    }

    private static func movementBounds(
        in visibleFrame: NSRect,
        petSize: NSSize,
        position: DesktopPetPosition
    ) -> NSRect {
        guard position != .fixed else {
            return NSRect(
                x: visibleFrame.midX - petSize.width / 2,
                y: visibleFrame.minY,
                width: petSize.width,
                height: petSize.height
            )
        }
        let isLeft = position == .topLeft || position == .bottomLeft
        let isTop = position == .topLeft || position == .topRight
        return NSRect(
            x: isLeft ? visibleFrame.minX : visibleFrame.midX,
            y: isTop ? visibleFrame.maxY - petSize.height : visibleFrame.minY,
            width: visibleFrame.width / 2,
            height: petSize.height
        )
    }

    #if DEBUG
    private static func validateMovementBounds() {
        let visible = NSRect(x: 0, y: 0, width: 1000, height: 800)
        let size = NSSize(width: 140, height: 100)
        let topLeft = movementBounds(in: visible, petSize: size, position: .topLeft)
        let bottomRight = movementBounds(in: visible, petSize: size, position: .bottomRight)
        assert(topLeft == NSRect(x: 0, y: 700, width: 500, height: 100))
        assert(bottomRight == NSRect(x: 500, y: 0, width: 500, height: 100))
    }
    #endif
}

private struct DesktopPetOverlay: View {
    @ObservedObject var pet: PetStore
    @AppStorage("desktopPetPosition") private var position = DesktopPetPosition.bottomRight

    var body: some View {
        VStack(spacing: 2) {
            AnimatedPixelPet(
                kind: pet.kind,
                mood: pet.mood,
                hungry: pet.isHungry,
                sleepy: pet.isSleepy || pet.isFocusing,
                motion: position == .fixed ? .idle : .walking
            )
            .frame(width: 92, height: 80)
            Capsule().fill(.black.opacity(0.16)).frame(width: 74, height: 7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .contentShape(Rectangle())
    }
}
