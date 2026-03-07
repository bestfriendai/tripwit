import UIKit

/// Centralised haptic feedback. All methods are @MainActor — call from the main thread.
@MainActor
final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    // MARK: - Impact

    func light()  { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    func heavy()  { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }

    // MARK: - Notification

    func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    func error()   { UINotificationFeedbackGenerator().notificationOccurred(.error) }

    // MARK: - Selection

    func selectionChanged() { UISelectionFeedbackGenerator().selectionChanged() }
}
