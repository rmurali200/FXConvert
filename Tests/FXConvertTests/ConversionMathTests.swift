import Testing
@testable import FXConvert

struct ConversionMathTests {
    @Test func crossRateNormalCase() {
        // base USD; 1 USD = 0.87 EUR; 1 USD = 0.75 GBP -> 10 EUR = ~8.62 GBP
        let result = ConversionMath.crossRate(amount: 10, fromRate: 0.87, toRate: 0.75)
        #expect(result != nil)
        #expect(abs(result! - 10 * (0.75 / 0.87)) < 0.0001)
    }

    @Test func crossRateIdentity() {
        #expect(ConversionMath.crossRate(amount: 42, fromRate: 1.0, toRate: 1.0) == 42)
    }

    @Test func crossRateNilWhenFromRateIsZero() {
        #expect(ConversionMath.crossRate(amount: 10, fromRate: 0, toRate: 1.5) == nil)
    }

    @Test func crossRateNilWhenRateMissing() {
        #expect(ConversionMath.crossRate(amount: 10, fromRate: nil, toRate: 1.5) == nil)
        #expect(ConversionMath.crossRate(amount: 10, fromRate: 1.5, toRate: nil) == nil)
    }

    @Test func filterAmountInputPlainInteger() {
        #expect(ConversionMath.filterAmountInput("123") == "123")
    }

    @Test func filterAmountInputStripsNonNumeric() {
        #expect(ConversionMath.filterAmountInput("1a2b.3c") == "12.3")
    }

    @Test func filterAmountInputKeepsOnlyFirstDecimalPoint() {
        #expect(ConversionMath.filterAmountInput("1.2.3") == "1.23")
    }

    @Test func filterAmountInputNormalizesCommaToDot() {
        #expect(ConversionMath.filterAmountInput("1,5") == "1.5")
    }

    @Test func filterAmountInputMixedCommaAndDotKeepsFirstSeparator() {
        #expect(ConversionMath.filterAmountInput("1,2.3") == "1.23")
    }

    @Test func filterAmountInputEmptyString() {
        #expect(ConversionMath.filterAmountInput("") == "")
    }
}
