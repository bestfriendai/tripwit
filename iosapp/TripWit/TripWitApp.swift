import SwiftUI
import CoreData
import os.log

private let appLog = Logger(subsystem: "com.kevinbuckley.travelplanner", category: "App")

@main
struct TripWitApp: App {

    let persistence = PersistenceController.shared
    @State private var locationManager = LocationManager()
    @State private var pendingImportURL: URL?
    @State private var pendingQuickAction: QuickActionService.ShortcutType?

    init() {
        QuickActionService.registerShortcuts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                pendingImportURL: $pendingImportURL,
                pendingQuickAction: $pendingQuickAction
            )
            .environment(locationManager)
            .environment(\.managedObjectContext, persistence.viewContext)
            .onOpenURL { url in
                handleIncomingURL(url)
            }
        }
    }

    /// Route incoming URLs — only .tripwit file imports
    private func handleIncomingURL(_ url: URL) {
        appLog.info("[URL] Received URL: \(url.absoluteString)")

        if url.pathExtension == "tripwit" {
            pendingImportURL = url
        } else {
            appLog.warning("[URL] Unhandled URL: \(url.absoluteString)")
        }
    }
}

// MARK: - UIApplicationDelegate (Quick Actions)

final class AppDelegate: NSObject, UIApplicationDelegate {

    var pendingQuickActionType: QuickActionService.ShortcutType?

    /// Called when app is already running and user taps a quick action.
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        pendingQuickActionType = QuickActionService.type(for: shortcutItem)
        completionHandler(pendingQuickActionType != nil)
    }
}
