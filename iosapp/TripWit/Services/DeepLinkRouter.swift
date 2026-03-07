import Foundation

/// Parses and generates `tripwit://` deep links.
///
/// Supported schemes:
///   tripwit://trip/<uuid>            → open trip detail
///   tripwit://stop/<uuid>            → open stop detail (within its trip)
///   tripwit://new-trip               → open the new-trip sheet
///   tripwit://active                 → jump to the currently active trip
///
/// URLs are also valid as universal links when hosted at:
///   https://tripwit.app/trip/<uuid>
enum DeepLinkRouter {

    // MARK: - Route Model

    enum Route: Equatable {
        case trip(id: UUID)
        case stop(id: UUID)
        case newTrip
        case activeTrip
    }

    // MARK: - Parsing

    /// Parse a `tripwit://` URL into a `Route`. Returns nil if unrecognised.
    static func route(from url: URL) -> Route? {
        // Normalise: both custom scheme and https are handled
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        let host = components.host ?? ""
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        // Custom scheme: tripwit://<host>[/<path>]
        if url.scheme?.lowercased() == "tripwit" {
            return parseRoute(host: host, pathComponents: pathComponents)
        }

        // Universal link: https://tripwit.app/<host>[/<path>]
        if url.scheme?.lowercased() == "https" && host == "tripwit.app" {
            let parts = pathComponents  // e.g. ["trip", "<uuid>"]
            return parseRoute(host: parts.first ?? "", pathComponents: Array(parts.dropFirst()))
        }

        return nil
    }

    private static func parseRoute(host: String, pathComponents: [String]) -> Route? {
        switch host.lowercased() {
        case "trip":
            guard let uuidString = pathComponents.first,
                  let uuid = UUID(uuidString: uuidString) else { return nil }
            return .trip(id: uuid)

        case "stop":
            guard let uuidString = pathComponents.first,
                  let uuid = UUID(uuidString: uuidString) else { return nil }
            return .stop(id: uuid)

        case "new-trip", "newtrip", "new_trip":
            return .newTrip

        case "active":
            return .activeTrip

        default:
            return nil
        }
    }

    // MARK: - Generation

    /// Generate a `tripwit://trip/<uuid>` URL for a trip ID.
    static func url(forTripID id: UUID) -> URL {
        URL(string: "tripwit://trip/\(id.uuidString)")!
    }

    /// Generate a `tripwit://stop/<uuid>` URL for a stop ID.
    static func url(forStopID id: UUID) -> URL {
        URL(string: "tripwit://stop/\(id.uuidString)")!
    }

    /// Generate a `tripwit://new-trip` URL.
    static var newTripURL: URL {
        URL(string: "tripwit://new-trip")!
    }

    /// Generate a `tripwit://active` URL.
    static var activeTripURL: URL {
        URL(string: "tripwit://active")!
    }
}
