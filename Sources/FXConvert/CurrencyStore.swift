import Foundation
import SwiftUI

@MainActor
final class CurrencyStore: ObservableObject {
    private static let staleAfter: TimeInterval = 4 * 3600

    @Published var rates: [String: Double] = [:]
    @Published var lastUpdated: Date?
    @Published var isOffline = false

    @AppStorage("amountText") var amountText: String = "1"
    @AppStorage("fromCurrency") var fromCurrency: String = "USD"
    @AppStorage("toCurrency") var toCurrency: String = "EUR"

    var sortedCurrencyCodes: [String] {
        rates.keys.sorted()
    }

    var amount: Double {
        Double(amountText) ?? 0
    }

    var result: Double? {
        guard let fromRate = rates[fromCurrency], let toRate = rates[toCurrency], fromRate > 0 else {
            return nil
        }
        // rates are all relative to a common base, so cross-rate = amount * (toRate / fromRate)
        return amount * (toRate / fromRate)
    }

    init() {
        if let cached = RatesCache.load() {
            rates = cached.rates
            lastUpdated = cached.fetchedAt
        }
        Task { await refreshIfStale() }
    }

    func swapCurrencies() {
        (fromCurrency, toCurrency) = (toCurrency, fromCurrency)
    }

    func refreshIfStale() async {
        if let lastUpdated, Date().timeIntervalSince(lastUpdated) < Self.staleAfter {
            return
        }
        await refresh()
    }

    func refresh() async {
        do {
            let response = try await RatesService.fetchLatest()
            rates = response.rates
            lastUpdated = Date()
            isOffline = false
            RatesCache.save(CachedRates(base: response.base, rates: response.rates, fetchedAt: lastUpdated!))
        } catch {
            // Keep whatever rates are already cached/loaded; just flag that we're stale.
            isOffline = true
        }
    }
}
