import Foundation
import SwiftUI

@MainActor
final class CurrencyStore: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var lastUpdated: Date?
    @Published var isOffline = false

    @AppStorage("amountText") var amountText: String = "1"
    @AppStorage("fromCurrency") var fromCurrency: String = "USD"
    @AppStorage("toCurrency") var toCurrency: String = "EUR"
    @AppStorage("favoriteCurrencies") private var favoriteCurrenciesRaw: String = "USD,EUR,GBP,JPY,INR,CAD,AUD,CHF,CNY"
    @AppStorage("refreshIntervalHours") var refreshIntervalHours: Double = 4
    @AppStorage("decimalPrecision") var decimalPrecision: Int = 4

    var sortedCurrencyCodes: [String] {
        rates.keys.sorted()
    }

    /// Ordered, de-duplicated list of currency codes the user has starred as favorites.
    /// Persisted as a comma-joined string since ISO 4217 codes never contain commas.
    var favoriteCurrencyCodes: [String] {
        get {
            favoriteCurrenciesRaw.split(separator: ",").map(String.init)
        }
        set {
            var seen = Set<String>()
            let deduped = newValue.filter { seen.insert($0).inserted }
            let removed = Set(favoriteCurrencyCodes).subtracting(deduped)
            favoriteCurrenciesRaw = deduped.joined(separator: ",")

            // If the currently-selected from/to currency was just unfavorited, fall back to
            // whatever favorites remain so the Picker binding never points at a removed option.
            if removed.contains(fromCurrency) {
                fromCurrency = deduped.first(where: { $0 != toCurrency }) ?? deduped.first ?? fromCurrency
            }
            if removed.contains(toCurrency) {
                toCurrency = deduped.first(where: { $0 != fromCurrency }) ?? deduped.first ?? toCurrency
            }
        }
    }

    var amount: Double {
        Double(amountText) ?? 0
    }

    var result: Double? {
        ConversionMath.crossRate(amount: amount, fromRate: rates[fromCurrency], toRate: rates[toCurrency])
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
        if let lastUpdated, Date().timeIntervalSince(lastUpdated) < refreshIntervalHours * 3600 {
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
            RatesCache.save(CachedRates(base: response.base_code, rates: response.rates, fetchedAt: lastUpdated!))
        } catch {
            // Keep whatever rates are already cached/loaded; just flag that we're stale.
            isOffline = true
        }
    }
}
