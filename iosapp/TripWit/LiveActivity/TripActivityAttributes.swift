import ActivityKit
import Foundation

/// Shared Live Activity attributes — must be identical in TripWitWidget target.
struct TripActivityAttributes: ActivityAttributes {
    public typealias ContentState = TripActivityState

    var tripName: String
    var destination: String

    struct TripActivityState: Codable, Hashable {
        var nextStopName: String
        var nextStopCategory: String
        var visitedStops: Int
        var totalStops: Int
        var daysRemaining: Int
        var statusMessage: String
    }
}
