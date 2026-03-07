import ActivityKit
import WidgetKit
import SwiftUI
import Foundation

// MARK: - Attributes (must match TripActivityAttributes.swift in main app)

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

// MARK: - Lock Screen / Banner View

struct TripLiveActivityView: View {
    let context: ActivityViewContext<TripActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.tripName)
                    .font(.headline)
                    .lineLimit(1)
                Text(context.attributes.destination)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(context.state.visitedStops)/\(context.state.totalStops)")
                    .font(.title3).bold()
                Text("stops")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Label(context.state.nextStopName, systemImage: categoryIcon(context.state.nextStopCategory))
                    .font(.caption)
                    .lineLimit(1)
                Text("Next")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func categoryIcon(_ raw: String) -> String {
        switch raw {
        case "restaurant": "fork.knife"
        case "attraction": "star.fill"
        case "accommodation": "bed.double.fill"
        case "transport": "car.fill"
        case "activity": "figure.walk"
        default: "mappin.circle.fill"
        }
    }
}

// MARK: - Widget Registration

@available(iOSApplicationExtension 16.2, *)
struct TripWitLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            TripLiveActivityView(context: context)
                .activityBackgroundTint(Color(.systemBackground))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.tripName).font(.headline).lineLimit(1)
                        Text(context.attributes.destination).font(.caption).foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.visitedStops)/\(context.state.totalStops)")
                            .font(.title3).bold()
                        Text("visited").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label(context.state.nextStopName, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                }
            } compactLeading: {
                Image(systemName: "airplane.departure").foregroundStyle(.blue)
            } compactTrailing: {
                Text("\(context.state.visitedStops)/\(context.state.totalStops)")
                    .font(.caption2).bold()
            } minimal: {
                Image(systemName: "mappin.circle.fill").foregroundStyle(.blue)
            }
        }
    }
}
