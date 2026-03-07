import UIKit

/// Manages home screen quick actions (long-press app icon shortcuts).
enum QuickActionService {

    enum ShortcutType: String {
        case viewActiveTrip  = "com.kevinbuckley.travelplanner.viewActiveTrip"
        case addNewTrip      = "com.kevinbuckley.travelplanner.addNewTrip"
        case markNextVisited = "com.kevinbuckley.travelplanner.markNextVisited"
    }

    // MARK: - Registration

    /// Call once at app launch to register the three home screen shortcuts.
    static func registerShortcuts() {
        UIApplication.shared.shortcutItems = buildShortcutItems()
    }

    static func buildShortcutItems() -> [UIApplicationShortcutItem] {
        [
            UIApplicationShortcutItem(
                type: ShortcutType.viewActiveTrip.rawValue,
                localizedTitle: "Active Trip",
                localizedSubtitle: "Jump to your current trip",
                icon: UIApplicationShortcutIcon(systemImageName: "airplane"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: ShortcutType.addNewTrip.rawValue,
                localizedTitle: "New Trip",
                localizedSubtitle: "Start planning",
                icon: UIApplicationShortcutIcon(systemImageName: "plus.circle"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: ShortcutType.markNextVisited.rawValue,
                localizedTitle: "Mark Next Stop",
                localizedSubtitle: "Mark today's next stop visited",
                icon: UIApplicationShortcutIcon(systemImageName: "checkmark.circle"),
                userInfo: nil
            ),
        ]
    }

    // MARK: - Handling

    /// Returns the `ShortcutType` for a given shortcut item, or nil if unrecognised.
    static func type(for item: UIApplicationShortcutItem) -> ShortcutType? {
        ShortcutType(rawValue: item.type)
    }

    /// Human-readable title for a shortcut type — useful in tests and analytics.
    static func title(for type: ShortcutType) -> String {
        switch type {
        case .viewActiveTrip:  "Active Trip"
        case .addNewTrip:      "New Trip"
        case .markNextVisited: "Mark Next Stop"
        }
    }

    /// SF Symbol name for each shortcut type.
    static func systemImage(for type: ShortcutType) -> String {
        switch type {
        case .viewActiveTrip:  "airplane"
        case .addNewTrip:      "plus.circle"
        case .markNextVisited: "checkmark.circle"
        }
    }
}
