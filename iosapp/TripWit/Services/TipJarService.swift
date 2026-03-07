import StoreKit
import Foundation

/// Manages the tip jar using StoreKit 2.
/// Product IDs must be configured in App Store Connect → In-App Purchases.
@Observable
@MainActor
final class TipJarService {

    // MARK: - Product IDs

    enum TipProduct: String, CaseIterable {
        case small  = "com.kevinbuckley.travelplanner.tip.small"
        case medium = "com.kevinbuckley.travelplanner.tip.medium"
        case large  = "com.kevinbuckley.travelplanner.tip.large"

        var emoji: String {
            switch self {
            case .small:  "☕️"
            case .medium: "🍕"
            case .large:  "🎉"
            }
        }

        var label: String {
            switch self {
            case .small:  "Small Tip"
            case .medium: "Medium Tip"
            case .large:  "Large Tip"
            }
        }
    }

    // MARK: - State

    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var purchaseError: String?
    private(set) var thankYouMessage: String?

    private var _updateListenerTask: Task<Void, Error>?

    init() {
        _updateListenerTask = listenForTransactions()
    }

    // MARK: - Loading

    func loadProducts() async {
        isLoading = true
        purchaseError = nil
        do {
            let ids = TipProduct.allCases.map { $0.rawValue }
            let fetched = try await Product.products(for: ids)
            // Sort in defined order
            products = TipProduct.allCases.compactMap { tip in
                fetched.first { $0.id == tip.rawValue }
            }
        } catch {
            purchaseError = "Could not load products: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Purchasing

    func purchase(_ product: Product) async {
        purchaseError = nil
        thankYouMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                thankYouMessage = "Thank you so much! Your support keeps TripWit going ✈️"
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await transaction.finish()
                } catch {
                    // Verification failure — ignore
                }
            }
        }
    }

    // MARK: - Helpers

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw TipError.failedVerification
        case .verified(let value):
            return value
        }
    }

    // MARK: - Sorted products for display

    /// Returns products sorted in the defined TipProduct order.
    func sortedProducts() -> [(product: Product, tip: TipProduct)] {
        TipProduct.allCases.compactMap { tip in
            guard let product = products.first(where: { $0.id == tip.rawValue }) else { return nil }
            return (product, tip)
        }
    }

    // MARK: - Static Helpers (testable without StoreKit)

    /// Whether the given product ID belongs to a known tip product.
    nonisolated static func isKnownProduct(_ id: String) -> Bool {
        TipProduct.allCases.map { $0.rawValue }.contains(id)
    }

    /// The TipProduct case for a given product ID, if any.
    nonisolated static func tipProduct(for id: String) -> TipProduct? {
        TipProduct(rawValue: id)
    }
}

// MARK: - Errors

enum TipError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification: "Transaction verification failed"
        }
    }
}
