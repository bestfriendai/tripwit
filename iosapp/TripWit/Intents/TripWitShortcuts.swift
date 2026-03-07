import AppIntents
import CoreData
import Foundation

// MARK: - App Shortcuts Provider

struct TripWitShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowActiveTripIntent(),
            phrases: [
                "Show my active trip in \(.applicationName)",
                "Open my trip in \(.applicationName)",
                "What's my itinerary in \(.applicationName)"
            ],
            shortTitle: "Show Active Trip",
            systemImageName: "map"
        )
        AppShortcut(
            intent: GetNextStopIntent(),
            phrases: [
                "What's my next stop in \(.applicationName)",
                "Where am I going next in \(.applicationName)",
                "Next stop in \(.applicationName)"
            ],
            shortTitle: "Next Stop",
            systemImageName: "location.fill"
        )
        AppShortcut(
            intent: GetTripStatsIntent(),
            phrases: [
                "Show my trip stats in \(.applicationName)",
                "How's my trip going in \(.applicationName)"
            ],
            shortTitle: "Trip Stats",
            systemImageName: "chart.bar"
        )
    }
}

// MARK: - Show Active Trip

struct ShowActiveTripIntent: AppIntent {
    static let title: LocalizedStringResource = "Show Active Trip"
    static let description = IntentDescription("Opens TripWit and shows your currently active trip.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trip = await fetchActiveTrip()
        if let trip {
            return .result(dialog: "Opening \(trip.wrappedName) to \(trip.wrappedDestination).")
        } else {
            return .result(dialog: "You don't have an active trip right now.")
        }
    }
}

// MARK: - Get Next Stop

struct GetNextStopIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Next Stop"
    static let description = IntentDescription("Tells you your next unvisited stop on the active trip.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let trip = await fetchActiveTrip() else {
            return .result(dialog: "You don't have an active trip right now.")
        }

        let today = Calendar.current.startOfDay(for: Date())
        let todayStops = trip.daysArray
            .filter { Calendar.current.startOfDay(for: $0.wrappedDate) == today }
            .flatMap(\.stopsArray)
            .filter { !$0.isVisited }
            .sorted { $0.sortOrder < $1.sortOrder }

        if let next = todayStops.first {
            let msg = next.arrivalTime.map {
                "Your next stop is \(next.wrappedName) at \(timeString($0))."
            } ?? "Your next stop is \(next.wrappedName)."
            return .result(dialog: "\(msg)")
        }

        let allRemaining = trip.daysArray
            .flatMap(\.stopsArray)
            .filter { !$0.isVisited }
        if let next = allRemaining.first {
            return .result(dialog: "No more stops today. Next up: \(next.wrappedName).")
        }

        return .result(dialog: "You've visited all your stops — great trip!")
    }
}

// MARK: - Get Trip Stats

struct GetTripStatsIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Trip Stats"
    static let description = IntentDescription("Gives you a quick summary of your active trip progress.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let trip = await fetchActiveTrip() else {
            return .result(dialog: "You don't have an active trip right now.")
        }

        let allStops = trip.daysArray.flatMap(\.stopsArray)
        let visited = allStops.filter(\.isVisited).count
        let total = allStops.count
        let daysLeft: Int = {
            guard let end = trip.endDate else { return 0 }
            return max(0, Calendar.current.dateComponents([.day], from: Date(), to: end).day ?? 0)
        }()

        let msg = "You're on \(trip.wrappedName) to \(trip.wrappedDestination). " +
            "\(visited) of \(total) stops visited. \(daysLeft) day\(daysLeft == 1 ? "" : "s") remaining."
        return .result(dialog: "\(msg)")
    }
}

// MARK: - Helpers

private func fetchActiveTrip() async -> TripEntity? {
    await MainActor.run {
        let context = PersistenceController.shared.container.viewContext
        let request = TripEntity.fetchRequest() as! NSFetchRequest<TripEntity>
        request.predicate = NSPredicate(format: "statusRaw == %@", "active")
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first
    }
}

private func timeString(_ date: Date) -> String {
    let f = DateFormatter()
    f.timeStyle = .short
    return f.string(from: date)
}
