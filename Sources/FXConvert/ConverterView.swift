import SwiftUI

struct ConverterView: View {
    @EnvironmentObject var store: CurrencyStore

    private static let resultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FXConvert")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 12) {
                GridRow {
                    TextField("Amount", text: $store.amountText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .onChange(of: store.amountText) { newValue in
                            let filtered = Self.filterAmountInput(newValue)
                            if filtered != newValue {
                                store.amountText = filtered
                            }
                        }

                    Picker("", selection: $store.fromCurrency) {
                        ForEach(store.sortedCurrencyCodes, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 90)
                }

                GridRow {
                    Button {
                        store.swapCurrencies()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .buttonStyle(.borderless)
                }

                GridRow {
                    Text(resultText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 100, alignment: .leading)

                    Picker("", selection: $store.toCurrency) {
                        ForEach(store.sortedCurrencyCodes, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 90)
                }
            }

            Divider()

            HStack {
                if store.isOffline {
                    Image(systemName: "wifi.slash")
                        .foregroundStyle(.secondary)
                }
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Refresh") {
                    Task { await store.refresh() }
                }
                .font(.caption)
            }
        }
        .padding()
        .frame(width: 260)
    }

    private var resultText: String {
        guard let result = store.result else { return "—" }
        return Self.resultFormatter.string(from: NSNumber(value: result)) ?? "—"
    }

    private var statusText: String {
        guard let lastUpdated = store.lastUpdated else { return "No rates yet" }
        let prefix = store.isOffline ? "Offline · last updated " : "Updated "
        return prefix + Self.timeFormatter.string(from: lastUpdated)
    }

    /// Keeps only digits and a single decimal point, so the field never holds unparseable text.
    private static func filterAmountInput(_ text: String) -> String {
        var result = ""
        var seenDecimalPoint = false
        for character in text {
            if character.isNumber {
                result.append(character)
            } else if character == ".", !seenDecimalPoint {
                seenDecimalPoint = true
                result.append(character)
            }
        }
        return result
    }
}
