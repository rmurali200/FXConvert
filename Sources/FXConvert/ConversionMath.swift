import Foundation

enum ConversionMath {
    /// rates are all relative to a common base, so cross-rate = amount * (toRate / fromRate)
    static func crossRate(amount: Double, fromRate: Double?, toRate: Double?) -> Double? {
        guard let fromRate, let toRate, fromRate > 0 else { return nil }
        return amount * (toRate / fromRate)
    }

    /// Keeps only digits and a single decimal point, so the field never holds unparseable text.
    /// A comma is treated as a decimal point (European input convention) and normalized to "."
    /// so downstream `Double(_:)` parsing never needs to special-case locale.
    static func filterAmountInput(_ text: String) -> String {
        var result = ""
        var seenDecimalPoint = false
        for character in text {
            if character.isNumber {
                result.append(character)
            } else if (character == "." || character == ","), !seenDecimalPoint {
                seenDecimalPoint = true
                result.append(".")
            }
        }
        return result
    }
}
