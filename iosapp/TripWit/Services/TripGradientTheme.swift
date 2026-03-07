import SwiftUI
import TripCore

/// Deterministic visual theme (gradient + accent color) for a trip.
///
/// - Active trips always receive a green/mint gradient — a consistent "you're here" signal.
/// - Planning trips pick one of four palettes based on the destination name, so the same
///   destination always produces the same colors but different destinations look distinct.
/// - Completed trips receive a neutral gray.
struct TripGradientTheme {

    // MARK: - Properties

    let gradient: LinearGradient
    let accentColor: Color
    /// Stable string key used in tests ("green", "blue", "orange", "indigo", "teal", "gray").
    let colorName: String

    // MARK: - Factory

    /// Returns the theme for a trip entity.
    static func theme(for trip: TripEntity) -> TripGradientTheme {
        theme(status: trip.displayStatus, destination: trip.wrappedDestination)
    }

    /// Returns the theme given an explicit status and optional destination string.
    static func theme(status: TripStatus, destination: String = "") -> TripGradientTheme {
        switch status {

        case .active:
            return TripGradientTheme(
                gradient: LinearGradient(
                    colors: [.green, .mint],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                accentColor: .green,
                colorName: "green"
            )

        case .planning:
            // 4 complementary palettes — destination determines which
            let palettes: [(Color, Color, String)] = [
                (.blue,   .purple, "blue"),
                (.orange, .red,    "orange"),
                (.indigo, .blue,   "indigo"),
                (.teal,   .cyan,   "teal"),
            ]
            let idx = destinationHash(destination) % 4
            let (start, end, name) = palettes[idx]
            return TripGradientTheme(
                gradient: LinearGradient(
                    colors: [start, end],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                accentColor: start,
                colorName: name
            )

        case .completed:
            return TripGradientTheme(
                gradient: LinearGradient(
                    colors: [Color(.systemGray2), Color(.systemGray3)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                accentColor: .gray,
                colorName: "gray"
            )
        }
    }

    // MARK: - Destination Hash

    /// Stable, non-negative integer derived from `destination`.
    /// Identical inputs always produce identical outputs; empty string → 0.
    static func destinationHash(_ destination: String) -> Int {
        guard !destination.isEmpty else { return 0 }
        let raw = destination.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
        return abs(raw)
    }
}
