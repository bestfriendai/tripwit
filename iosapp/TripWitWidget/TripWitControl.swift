import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Control Value

struct TripControlValue {
    let tripName: String?
    let nextStop: String?
    let visitedCount: Int
    let totalCount: Int

    static let empty = TripControlValue(tripName: nil, nextStop: nil, visitedCount: 0, totalCount: 0)

    var displayName: String { tripName ?? "TripWit" }
    var progressLabel: String {
        guard totalCount > 0 else { return "No stops" }
        return "\(visitedCount)/\(totalCount)"
    }
}

// MARK: - Widget-local AppIntents

struct OpenActiveTripIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Active Trip"
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult { .result() }
}

struct OpenNextStopIntent: AppIntent {
    static var title: LocalizedStringResource = "View Next Stop"
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult { .result() }
}

// MARK: - Provider

struct TripControlProvider: ControlValueProvider {
    typealias Value = TripControlValue

    var previewValue: TripControlValue {
        TripControlValue(tripName: "Paris Trip", nextStop: "Eiffel Tower", visitedCount: 2, totalCount: 5)
    }

    func currentValue() async throws -> TripControlValue {
        guard let data = WidgetReader.read() else { return .empty }
        return TripControlValue(
            tripName:     data.tripName,
            nextStop:     data.nextStopName,
            visitedCount: data.visitedStops,
            totalCount:   data.totalStops
        )
    }
}

// MARK: - Active Trip Control Widget

@available(iOS 18.0, *)
struct TripWitControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.kevinbuckley.travelplanner.control",
            provider: TripControlProvider()
        ) { value in
            ControlWidgetButton(action: OpenActiveTripIntent()) {
                Label {
                    Text(value.displayName)
                        .font(.caption2.weight(.semibold))
                } icon: {
                    Image(systemName: "airplane.departure")
                }
            }
        }
        .displayName("Active Trip")
        .description("Open TripWit to your active trip.")
    }
}

// MARK: - Next Stop Control Widget

@available(iOS 18.0, *)
struct TripWitMarkStopControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.kevinbuckley.travelplanner.markStop",
            provider: TripControlProvider()
        ) { value in
            ControlWidgetButton(action: OpenNextStopIntent()) {
                Label {
                    Text(value.progressLabel)
                        .font(.caption2.weight(.semibold))
                } icon: {
                    Image(systemName: value.visitedCount == value.totalCount
                          ? "checkmark.circle.fill"
                          : "mappin.circle")
                }
            }
        }
        .displayName("Next Stop")
        .description("See today's next stop from Control Center.")
    }
}
