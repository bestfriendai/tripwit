import ActivityKit
import Foundation

/// Manages the Live Activity for the currently active trip.
@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {}

    private var currentActivity: Activity<TripActivityAttributes>?

    // MARK: - Start

    func startActivity(for trip: TripEntity) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // End any existing activity first
        endActivity()

        let state = buildState(from: trip)
        let attrs = TripActivityAttributes(
            tripName: trip.wrappedName,
            destination: trip.wrappedDestination
        )

        let content = ActivityContent(state: state, staleDate: nil)
        currentActivity = try? Activity.request(
            attributes: attrs,
            content: content,
            pushType: nil
        )
    }

    // MARK: - Update

    func updateActivity(for trip: TripEntity) {
        guard let activity = currentActivity else {
            // Try to find an existing activity
            currentActivity = Activity<TripActivityAttributes>.activities.first
            guard currentActivity != nil else { return }
            updateActivity(for: trip)
            return
        }

        let state = buildState(from: trip)
        let content = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(content)
        }
    }

    // MARK: - End

    func endActivity() {
        Task {
            for activity in Activity<TripActivityAttributes>.activities {
                let finalState = activity.content.state
                let content = ActivityContent(
                    state: TripActivityAttributes.TripActivityState(
                        nextStopName: "Trip complete",
                        nextStopCategory: "other",
                        visitedStops: finalState.visitedStops,
                        totalStops: finalState.totalStops,
                        daysRemaining: 0,
                        statusMessage: "Trip ended"
                    ),
                    staleDate: nil
                )
                await activity.end(content, dismissalPolicy: .after(.now + 5))
            }
            currentActivity = nil
        }
    }

    // MARK: - Helpers

    private func buildState(from trip: TripEntity) -> TripActivityAttributes.TripActivityState {
        let calendar = Calendar.current
        let allStops = trip.daysArray.flatMap(\.stopsArray)
        let visited = allStops.filter(\.isVisited).count
        let today = calendar.startOfDay(for: Date())

        let nextStop = trip.daysArray
            .filter { calendar.startOfDay(for: $0.wrappedDate) >= today }
            .sorted { $0.dayNumber < $1.dayNumber }
            .flatMap(\.stopsArray)
            .filter { !$0.isVisited }
            .sorted { $0.sortOrder < $1.sortOrder }
            .first

        let daysLeft = trip.endDate.map {
            max(0, calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: $0)).day ?? 0)
        } ?? 0

        let message: String
        if daysLeft == 0 { message = "Last day!" }
        else if daysLeft == 1 { message = "1 day remaining" }
        else { message = "\(daysLeft) days remaining" }

        return TripActivityAttributes.TripActivityState(
            nextStopName: nextStop?.wrappedName ?? "No more stops",
            nextStopCategory: nextStop?.category.rawValue ?? "other",
            visitedStops: visited,
            totalStops: allStops.count,
            daysRemaining: daysLeft,
            statusMessage: message
        )
    }
}
